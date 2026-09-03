# Telegram → Obsidian inbox daemon

`telegram-obsidian-inbox.py` long-polls a private Telegram bot and appends text messages to:

```text
~/Documents/Notes/Inbox/YYYY-MM-DD.md
```

It runs as the `telegram-obsidian-inbox.service` NixOS system service. The service starts during boot, runs as user `n451`, and does not require Obsidian or Neovim to be open.

## Current behavior

- Accepts messages only from one configured numeric Telegram user ID.
- Accepts only private-chat text messages.
- Uses the message's Telegram timestamp in the machine's local timezone.
- Appends each message as a timestamped Markdown list item.
- Records a hidden `telegram:<chat-id>:<message-id>` marker to prevent duplicates.
- Persists the Telegram update offset under `~/.local/state/telegram-obsidian-inbox/`.
- Writes timestamped, rotating logs to `~/.local/state/telegram-obsidian-inbox/daemon.log` (up to three 1 MiB backups).
- Runs a one-time `ob sync` from the vault directory after saving each new message.
- Replies after processing and reports sync failures without discarding the saved note.
- Supports `/start` and `/status` without writing those commands to the vault.

Example:

```markdown
# Telegram Inbox — 2026-08-30

- `14:37` An idea captured while walking.
  <!-- telegram:123456789:42 -->
```

## Setup

### 1. Create a bot

1. Open [@BotFather](https://t.me/BotFather).
2. Send `/newbot` and follow its prompts.
3. Save the bot token.
4. Find your numeric Telegram user ID, for example through `@userinfobot`.

Use a dedicated personal bot. Do not add it to groups.

### 2. Create the secret environment file

The token must not be committed to this repository or stored in the vault.

```sh
install -Dm600 /dev/null ~/.config/telegram-obsidian-inbox.env
$EDITOR ~/.config/telegram-obsidian-inbox.env
```

Add:

```ini
TELEGRAM_BOT_TOKEN=123456789:replace-with-token-from-botfather
TELEGRAM_ALLOWED_USER_ID=123456789
```

The NixOS unit has a `ConditionPathExists` check, so it remains inactive when this file does not exist.

### 3. Rebuild NixOS

New files must be known to Git before a Git-backed Nix flake can reference them:

```sh
git -C ~/nixos-config add scripts/telegram-obsidian-inbox.py scripts/telegram-obsidian-inbox.md
# WSL:
sudo nixos-rebuild switch --flake ~/nixos-config#wsl
# Bare metal:
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

The service should start automatically. If the environment file was created after the rebuild, start it explicitly:

```sh
sudo systemctl start telegram-obsidian-inbox.service
```

### 4. Verify it

```sh
sudo systemctl status telegram-obsidian-inbox.service
sudo journalctl -u telegram-obsidian-inbox.service -f
```

Send `/status` to the bot, then send a normal text message. It should appear in today's inbox file and trigger a one-time Obsidian Sync. The vault must already be configured for the headless client (`ob sync-setup`).

## Operations

Inspect or follow the dedicated log file:

```sh
less ~/.local/state/telegram-obsidian-inbox/daemon.log
tail -F ~/.local/state/telegram-obsidian-inbox/daemon.log
```

The same output remains available in the systemd journal. `daemon.log.1` through `daemon.log.3` are retained automatically.

Restart after changing the environment file:

```sh
sudo systemctl restart telegram-obsidian-inbox.service
```

Stop or disable it:

```sh
sudo systemctl disable --now telegram-obsidian-inbox.service
```

The NixOS configuration enables it again on the next rebuild. To disable it permanently, remove or disable the unit in `configuration.nix`.

To reprocess any Telegram updates still retained by Telegram, stop the service and remove its offset:

```sh
sudo systemctl stop telegram-obsidian-inbox.service
rm ~/.local/state/telegram-obsidian-inbox/offset
sudo systemctl start telegram-obsidian-inbox.service
```

Telegram retains unconsumed bot updates for no longer than 24 hours. Removing the offset can therefore duplicate recent messages, although the markers in existing daily files prevent exact duplicates.

If the token leaks, revoke it immediately through `@BotFather`, update the environment file, and restart the service.

## Privacy and limitations

- Messages pass through Telegram and are not a private end-to-end-encrypted path into the vault.
- The bot token grants control of the bot. Keep the environment file mode at `0600`.
- Text is stored as written, without converting Telegram formatting entities to Markdown.
- Sync is attempted only for newly saved messages, not commands or duplicate updates. A sync failure is logged and reported to Telegram, while the local note remains saved.
- Photos, files, voice notes, message edits, and deletions are not yet supported.
- Only one process may poll a particular bot token. The daemon holds a local lock to avoid accidental duplicate instances.

## Future plans

Keep the capture path reliable and simple; additions should persist the original input before further processing.

- [ ] Download photos and documents into the vault's attachment directory.
- [ ] Save voice notes and optionally transcribe them with a local Whisper service.
- [ ] Add simple `/task`, `/journal`, and `/note` routing commands.
- [ ] Add Files.md-style inline buttons for routing an already-saved inbox entry.
- [ ] Preserve Telegram bold, italic, code, and link entities as Markdown.
- [ ] Add `/search` as a small, read-only vault search command.
- [ ] Add automated tests for authorization, restart recovery, multiline messages, and write failures.
- [ ] Consider systemd credentials or an encrypted secret manager instead of an environment file.
- [ ] Add optional health notifications after repeated polling or filesystem failures.
- [ ] Consider AI retrieval only after capture, routing, and access controls are stable.
