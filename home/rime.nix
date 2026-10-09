{
  config,
  lib,
  pkgs,
  ...
}: let
  fcitxRimeDir = "${config.xdg.dataHome}/fcitx5/rime";
  rimeLsDir = "${config.xdg.dataHome}/rime-ls";
  rimeDataDirs = ["fcitx5/rime" "rime-ls"];
  rimeFiles = [
    "custom_phrase.txt"
    "default.custom.yaml"
    "double_pinyin.custom.yaml"
    "double_pinyin_flypy.custom.yaml"
    "double_pinyin_flypy.schema.yaml"
    "double_pinyin.schema.yaml"
    "easy_en.dict.yaml"
    "easy_en.schema.yaml"
    "grammar.custom.yaml"
    "grammar.yaml"
    "luna_pinyin.dict.yaml"
    "luna_pinyin.extended.dict.yaml"
    "luna_pinyin_simp.custom.yaml"
    "luna_pinyin_simp.schema.yaml"
    "luna_pinyin.sogou.dict.yaml"
    "numbers.schema.yaml"
    "opencc/emoji_category.txt"
    "opencc/emoji.json"
    "opencc/emoji_word.txt"
    "opencc/es.json"
    "opencc/es.txt"
    "rime.lua"
    "squirrel.custom.yaml"
  ];
  rimeConfigVersion = builtins.hashString "sha256" (
    lib.concatMapStringsSep ":" (file: builtins.hashFile "sha256" (./rime + "/${file}")) rimeFiles
  );

  # Shared exchange directory for rime's native sync. Both the fcitx-rime and
  # rime-ls frontends point their sync_dir here; it is a Syncthing folder so
  # learned-word exports flow between the `nixos` and `wsl` targets.
  rimeSyncDir = "${config.home.homeDirectory}/sync/cmdline/rime";
in {
  home.sessionVariables = {
    # Fcitx and rime-ls must not share a live user directory: both lock the
    # LevelDB user dictionaries. They do share the same declarative schemas,
    # and rime-ls uses Fcitx's sync directory for learned-word exchange.
    RIME_USER_DATA_DIR = fcitxRimeDir;
    RIME_LS_USER_DATA_DIR = rimeLsDir;
  };

  # Keep generated build/, sync/, *.userdb, installation.yaml and user.yaml
  # writable while exposing exactly the same static 小鹤双拼 config to both
  # Fcitx and rime-ls.
  xdg.dataFile = builtins.listToAttrs (lib.concatMap (
      file:
        map (dir:
          lib.nameValuePair "${dir}/${file}" {
            source = ./rime + "/${file}";
          })
        rimeDataDirs
    )
    rimeFiles);

  # Nix store files have an epoch mtime, so librime cannot notice a changed
  # symlink target by timestamp. Invalidate only generated artifacts whenever
  # a managed schema changes; user dictionaries remain untouched.
  home.activation.invalidateRimeBuilds = lib.hm.dag.entryAfter ["writeBoundary"] ''
    for dir in ${lib.escapeShellArgs [fcitxRimeDir rimeLsDir]}; do
      version_file="$dir/.nix-config-version"
      $DRY_RUN_CMD mkdir -p "$dir"
      old_version="$(${pkgs.coreutils}/bin/cat "$version_file" 2>/dev/null || true)"
      if [ "$old_version" != "${rimeConfigVersion}" ]; then
        $DRY_RUN_CMD rm -rf "$dir/build"
        if [ -z "$DRY_RUN_CMD" ]; then
          printf '%s\n' '${rimeConfigVersion}' > "$version_file"
        fi
      fi
    done
  '';

  # Point both frontends' installation.yaml at the shared exchange directory.
  # fcitx-rime and rime-ls each keep their own installation_id and live userdb;
  # they only exchange plaintext *.userdb.txt snapshots through sync_dir, so
  # they never open each other's live database. :RimeSync (nvim) and fcitx's
  # "同步用户数据" both export/import through this directory.
  home.activation.setRimeSyncDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set_rime_sync_dir() {
      dir="$1"
      $DRY_RUN_CMD mkdir -p "$dir" "${rimeSyncDir}"
      installation="$dir/installation.yaml"
      if [ ! -e "$installation" ]; then
        if [ -z "$DRY_RUN_CMD" ]; then
          installation_id="$(${pkgs.coreutils}/bin/cat /proc/sys/kernel/random/uuid)"
          ${pkgs.coreutils}/bin/printf 'distribution_code_name: "rime"\ninstallation_id: "%s"\nsync_dir: "%s"\n' "$installation_id" "${rimeSyncDir}" > "$installation"
        fi
      elif ${pkgs.gnugrep}/bin/grep -q '^sync_dir:' "$installation"; then
        if [ -z "$DRY_RUN_CMD" ]; then
          ${pkgs.gnused}/bin/sed -i 's|^sync_dir:.*|sync_dir: "${rimeSyncDir}"|' "$installation"
        fi
      else
        if [ -z "$DRY_RUN_CMD" ]; then
          ${pkgs.coreutils}/bin/printf '\nsync_dir: "%s"\n' "${rimeSyncDir}" >> "$installation"
        fi
      fi
    }
    set_rime_sync_dir "${fcitxRimeDir}"
    set_rime_sync_dir "${rimeLsDir}"
  '';
}
