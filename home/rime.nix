{
  config,
  lib,
  ...
}: let
  rimeUserDataDir = "${config.xdg.dataHome}/fcitx5/rime";
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
in {
  home.sessionVariables = {
    RIME_USER_DATA_DIR = rimeUserDataDir;
  };

  # Keep the Rime user data directory writable for build/, sync/, *.userdb,
  # installation.yaml and user.yaml, but make the static config Nix-managed.
  xdg.dataFile = lib.genAttrs (map (file: "fcitx5/rime/${file}") rimeFiles) (
    target: let
      file = lib.removePrefix "fcitx5/rime/" target;
    in {
      source = ./rime + "/${file}";
    }
  );
}
