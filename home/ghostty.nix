{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      font-size = 10;
      # keybind = [ "ctrl+h=goto_split:left" "ctrl+l=goto_split:right" ];
      command = "fish";
    };
  };
}
