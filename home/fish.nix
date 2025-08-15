{
  programs.fish = {
    enable = true;
    shellAliases = {
      # vi =
      #   "VIMRUNTIME=~/Clone/neovim/runtime ~/Clone/neovim/build/bin/nvim --luamod-dev";
      vi = "nvim";
      timer = "~/bin/timer";
      pp = "~/scripts/wp";
      cat = "bat";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
      gss = "git status --short";
      ga = "git add";
      gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
      gc = "git commit";
      gp = "git push";
      gP = "git pull";
      gl = "git log";
      gb = "git branch";
      gi = "git init";
      gcl = "git clone";
      em = "emacs -nw";
    };
  };
}
