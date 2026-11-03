{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # theme = "catppuccin-mocha";
      background-opacity = 0.8;
      font-family = ["DejaVu Sans Mono" "Noto Sans Mono CJK SC"];
      # Noto CJK has no italic face; use Sarasa's real CJK italic faces.
      font-family-italic = ["DejaVu Sans Mono" "Sarasa Mono SC"];
      font-family-bold-italic = ["DejaVu Sans Mono" "Sarasa Mono SC"];
      font-size = 10;
      keybind = [
        # "ctrl+h=goto_split:left" "ctrl+l=goto_split:right"
        "ctrl+shift+c=unbind"
      ];
      command = "fish";
    };
  };
}
