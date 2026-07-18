{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    historyLimit = 100000;
    terminal = "tmux-256color";

    extraConfig = ''
      # Forward modified keys such as Shift+Enter and Ctrl+Enter.
      set -g extended-keys on

      # Useful defaults for terminal applications and long-running sessions.
      set -g focus-events on
      set -g renumber-windows on
      set -g set-clipboard on
    '';
  };
}
