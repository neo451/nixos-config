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

  # Seed a distinct, writable rime-ls installation. sync_dir intentionally
  # points at Fcitx's exchange directory; :RimeSync exports/imports through it
  # without either frontend opening the other's live database.
  home.activation.seedRimeLsInstallation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    installation="${rimeLsDir}/installation.yaml"
    $DRY_RUN_CMD mkdir -p "${rimeLsDir}" "${fcitxRimeDir}/sync"
    if [ ! -e "$installation" ]; then
      if [ -z "$DRY_RUN_CMD" ]; then
        installation_id="$(${pkgs.coreutils}/bin/cat /proc/sys/kernel/random/uuid)"
        ${pkgs.coreutils}/bin/cat > "$installation" <<EOF
    distribution_code_name: "rime-ls"
    distribution_name: "Rime LS"
    distribution_version: "0.4.3"
    installation_id: "$installation_id"
    sync_dir: "${fcitxRimeDir}/sync"
    EOF
      fi
    elif ! ${pkgs.gnugrep}/bin/grep -q '^sync_dir:' "$installation"; then
      if [ -z "$DRY_RUN_CMD" ]; then
        printf '\nsync_dir: "%s"\n' '${fcitxRimeDir}/sync' >> "$installation"
      fi
    fi
  '';
}
