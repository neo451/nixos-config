{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # theme = "catppuccin-mocha";
      theme = "pywal";
      background-opacity = 0.8;
      font-size = 10;
      keybind = [
        # "ctrl+h=goto_split:left" "ctrl+l=goto_split:right"
        "ctrl+shift+c=unbind"
      ];
      command = "fish";
    };
  };
}
