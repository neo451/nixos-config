#!/usr/bin/env python3
"""Long-poll a private Telegram bot and append text messages to an Obsidian inbox."""

from __future__ import annotations

import fcntl
import json
import os
import signal
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any

INBOX_DIR = Path("/home/n451/Documents/Notes/Inbox")
STATE_DIR = Path("/home/n451/.local/state/telegram-obsidian-inbox")
OFFSET_FILE = STATE_DIR / "offset"
LOCK_FILE = STATE_DIR / "daemon.lock"
POLL_TIMEOUT_SECONDS = 50

stopping = False


class TelegramError(RuntimeError):
    """A sanitized Telegram API or transport error."""


def log(message: str) -> None:
    print(message, flush=True)


def request_telegram(token: str, method: str, parameters: dict[str, Any]) -> Any:
    url = f"https://api.telegram.org/bot{token}/{method}"
    body = urllib.parse.urlencode(parameters).encode()
    request = urllib.request.Request(url, data=body, method="POST")

    try:
        with urllib.request.urlopen(
            request, timeout=POLL_TIMEOUT_SECONDS + 10
        ) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as error:
        try:
            payload = json.loads(error.read())
            description = payload.get("description", "unknown API error")
        except (json.JSONDecodeError, UnicodeDecodeError):
            description = "unknown API error"
        raise TelegramError(f"Telegram HTTP {error.code}: {description}") from None
    except urllib.error.URLError as error:
        raise TelegramError(f"Telegram connection failed: {error.reason}") from None
    except (json.JSONDecodeError, UnicodeDecodeError):
        raise TelegramError("Telegram returned invalid JSON") from None

    if not payload.get("ok"):
        raise TelegramError(
            f"Telegram API error: {payload.get('description', 'unknown error')}"
        )
    return payload["result"]


def load_offset() -> int | None:
    try:
        return int(OFFSET_FILE.read_text().strip())
    except FileNotFoundError:
        return None
    except ValueError:
        raise RuntimeError(f"Invalid update offset in {OFFSET_FILE}") from None


def save_offset(offset: int) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
    temporary = OFFSET_FILE.with_suffix(".tmp")
    temporary.write_text(f"{offset}\n")
    temporary.chmod(0o600)
    os.replace(temporary, OFFSET_FILE)


def acquire_instance_lock() -> Any:
    STATE_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
    lock = LOCK_FILE.open("w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        raise RuntimeError(
            "Another telegram-obsidian-inbox daemon is running"
        ) from None
    return lock


def append_message(message: dict[str, Any]) -> tuple[Path, bool]:
    text = message["text"].strip()
    timestamp = datetime.fromtimestamp(int(message["date"])).astimezone()
    target = INBOX_DIR / f"{timestamp:%Y-%m-%d}.md"
    marker = f"<!-- telegram:{message['chat']['id']}:{message['message_id']} -->"

    lines = text.splitlines()
    entry = f"- `{timestamp:%H:%M}` {lines[0]}"
    if len(lines) > 1:
        entry += "\n" + "\n".join(f"  {line}" for line in lines[1:])
    entry += f"\n  {marker}\n"

    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("a+", encoding="utf-8") as inbox:
        fcntl.flock(inbox, fcntl.LOCK_EX)
        inbox.seek(0)
        existing = inbox.read()
        if marker in existing:
            return target, False

        if not existing:
            inbox.write(f"# Telegram Inbox — {timestamp:%Y-%m-%d}\n\n")
        elif not existing.endswith("\n"):
            inbox.write("\n")
        inbox.write(entry)
        inbox.flush()
        os.fsync(inbox.fileno())

    return target, True


def reply_for_message(
    message: dict[str, Any], allowed_user_id: int
) -> tuple[int, str] | None:
    sender = message.get("from", {})
    chat = message.get("chat", {})
    if sender.get("id") != allowed_user_id or chat.get("type") != "private":
        log(f"Ignoring unauthorized update from user {sender.get('id', 'unknown')}")
        return None

    chat_id = int(chat["id"])
    text = message.get("text")
    if not text or not text.strip():
        return chat_id, "Only text messages are supported for now."

    command = text.split(maxsplit=1)[0].split("@", maxsplit=1)[0].lower()
    if command == "/start":
        return chat_id, "Ready. Send text and I will append it to your Obsidian inbox."
    if command == "/status":
        return chat_id, f"Running. Inbox: {INBOX_DIR}/YYYY-MM-DD.md"

    target, created = append_message(message)
    relative_target = target.relative_to(INBOX_DIR.parent)
    action = "Saved" if created else "Already saved"
    return chat_id, f"{action} to {relative_target} ✓"


def get_updates(token: str, offset: int | None) -> list[dict[str, Any]]:
    parameters: dict[str, Any] = {
        "timeout": POLL_TIMEOUT_SECONDS,
        "limit": 100,
        "allowed_updates": json.dumps(["message"]),
    }
    if offset is not None:
        parameters["offset"] = offset
    return request_telegram(token, "getUpdates", parameters)


def send_message(token: str, chat_id: int, text: str) -> None:
    request_telegram(token, "sendMessage", {"chat_id": chat_id, "text": text})


def stop(_signum: int, _frame: Any) -> None:
    global stopping
    stopping = True


def main() -> int:
    token = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
    allowed_user = os.environ.get("TELEGRAM_ALLOWED_USER_ID", "").strip()
    if not token or not allowed_user:
        log("TELEGRAM_BOT_TOKEN and TELEGRAM_ALLOWED_USER_ID must be configured")
        return 2
    try:
        allowed_user_id = int(allowed_user)
    except ValueError:
        log("TELEGRAM_ALLOWED_USER_ID must be an integer")
        return 2

    _instance_lock = acquire_instance_lock()
    offset = load_offset()
    backoff = 1
    log(f"Telegram inbox daemon started; writing to {INBOX_DIR}")

    while not stopping:
        try:
            updates = get_updates(token, offset)
            backoff = 1
            for update in updates:
                next_offset = int(update["update_id"]) + 1
                message = update.get("message")
                reply = reply_for_message(message, allowed_user_id) if message else None
                save_offset(next_offset)
                offset = next_offset

                if reply:
                    try:
                        send_message(token, *reply)
                    except TelegramError as error:
                        log(f"Warning: note was processed but reply failed: {error}")
        except (TelegramError, OSError, RuntimeError, KeyError, TypeError) as error:
            log(f"Error: {error}; retrying in {backoff}s")
            time.sleep(backoff)
            backoff = min(backoff * 2, 60)

    log("Telegram inbox daemon stopped")
    return 0


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    sys.exit(main())
