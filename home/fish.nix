{
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      timer = "~/bin/timer";
      pp = "~/scripts/wp";
      cat = "bat";
      rpi = "ssh -t fe3o4@172.20.10.14 'tmux attach 2>/dev/null || tmux new -s main'";
      nvim-dev = "VIMRUNTIME=/home/n451/Clone/neovim/runtime nvim --luamod-dev";
    };
    shellInit = ''
      set -gx BROWSER wsl-open
      fish_add_path ~/.npm-global/bin
      if test -f ~/.config/private-env
        source ~/.config/private-env
      end
      fish_add_path ~/bin/
      if test -f ~/secret/AI.fish
          source ~/secret/AI.fish
      end
      if test -f ~/secret/SPOTIFY.fish
          source ~/secret/SPOTIFY.fish
          set -q SPOTIFY_CLIENT_ID; and set -gx SPOTIFY_CLIENT_ID $SPOTIFY_CLIENT_ID
          set -q SPOTIFY_CLIENT_SECRET; and set -gx SPOTIFY_CLIENT_SECRET $SPOTIFY_CLIENT_SECRET
      end
      set LEDGER_FILE ~/Documents/Notes/ledger.md
      zoxide init fish | source
    '';
    shellAbbrs = {
      rack = "cd Binaries/Rack2Pro/ ; steam-run ./Rack";
      nfu = "cd ~/nixos-config; sudo nix flake update";
      nrs = "~/scripts/rebuild-os";
      gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
      em = "emacs -nw";
      cd = "z";
      lg = "lazygit";
      ls = "eza -lah";
    };
  };
}
