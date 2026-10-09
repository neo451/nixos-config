# Cross-target state sync (`nixos` ↔ `wsl`)

Software/tooling is shared via the flake. This documents the *state* that must
survive switching machines, carried over a Syncthing folder:

```
~/sync/cmdline/          # folder id: "cmdline", shared ONLY nixos ↔ wsl
├── zoxide/              # zoxide db (via _ZO_DATA_DIR)
├── pi/sessions/         # pi session JSONL (via PI_CODING_AGENT_SESSION_DIR)
└── rime/                # rime sync exchange dir (via sync_dir)
```

> Never add the phone device (`MNA-AL00`) to this folder — it carries state
> you don't want on other devices.

## Rebuild & activate (each machine, after `git pull`)

```sh
sudo nixos-rebuild switch --flake ~/nixos-config#nixos   # or #wsl
```

The activation writes `sync_dir`, `_ZO_DATA_DIR`, and
`PI_CODING_AGENT_SESSION_DIR` into your environment. New shells pick them up;
restart pi / editors to use the new locations.

## WSL pairing (one-time, on the WSL machine)

1. `systemctl --user enable --now syncthing`
2. In the Syncthing GUI (`http://127.0.0.1:8384`), add the `nixos` device
   (`BAAMJBZ-G26DSKO-FV3HJ53-4TCLWLV-D2OZHRL-XJBPQVT-JXY5FQY-JEWJ5AQ`).
3. On the `nixos` side, accept the WSL device, then share folder `cmdline`
   with it (Edit folder → Sharing → tick the WSL device). Path on WSL:
   `/home/n451/sync/cmdline`.
4. WSL will pull the already-seeded data. No manual copy needed.

## Rime (learned dictionary) — manual trigger

Rime's native sync is **not automatic**: you must *export* on one side and
*redeploy/import* on the other. The exchange dir is the Syncthing folder above,
so files flow automatically; only the export/import actions are manual.

- **nvim (rime-ls):** `:RimeSync` — exports local learned words to
  `~/sync/cmdline/rime/<installation_id>/` and imports others.
- **fcitx5 (desktop):** tray → 中州韻/“同步用户数据” (sync user data), then
  “重新部署” (redeploy) to import the other machine's snapshot.

Learned words are **merged** (union), never overwritten — safe to run on both
sides.

Optional slim-down: rime exports the full dict files (~46 MB per install). To
export only the learned userdb + custom phrases, add to `installation.yaml`:

```yaml
sync_user_data:
  - luna_pinyin.userdb
  - custom_phrase.txt
  - user.yaml
```

## Atuin (shell history) — one-time seed, already cloud-synced

Atuin already syncs to `api.atuin.sh` (`auto_sync` in `home/atuin.nix`). The
local DB is just a cache — **do not Syncthing it** (SQLite + WAL will corrupt).

The one thing that must match between machines is the encryption key:

1. On the new machine: `atuin login` (same account).
2. Copy the key from the existing machine and overwrite the fresh one:

   ```sh
   # on nixos
   cat ~/.local/share/atuin/key
   # on wsl, paste the value:
   printf '%s' '<KEY>' > ~/.local/share/atuin/key
   ```

3. `atuin sync` (or wait for `sync_frequency`). History now decrypts on both.

If keys differ, each machine can only read its own history.

## Caveats

- Syncthing is last-write-wins. Fine for one-machine-at-a-time use; don't run
  pi on both targets simultaneously or you'll get `.sync-conflict` session
  files.
- `~/.pi/agent/auth.json`, `~/.config/gh/hosts.yml`, and the atuin `key` are
  secrets — keep them out of any folder shared beyond these two machines.
- After confirming pi is writing sessions to `~/sync/cmdline/pi/sessions`,
  delete the old `~/.pi/agent/sessions/` to reclaim ~158 MB.
