{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # theme = "catppuccin-mocha";
      background-opacity = 0.8;
      # Use real Latin bold/oblique faces and the SC CJK family for Chinese glyphs.
      font-family = ["DejaVu Sans Mono" "Noto Sans Mono CJK SC"];
      font-size = 10;
      keybind = [
        # "ctrl+h=goto_split:left" "ctrl+l=goto_split:right"
        "ctrl+shift+c=unbind"
      ];
      command = "fish";
    };
  };
}
