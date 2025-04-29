{
  programs.fish = {
    enable = true;
    shellAliases = {
      # vi = "nvim";
      cat = "bat";
      em = "emacs -nw";
      vi =
        "VIMRUNTIME=~/Clone/neovim/runtime ~/Clone/neovim/build/bin/nvim --luamod-dev";
      markmap =
        "/home/n451/.local/share/nvim/lazy/markmap.nvim/node_modules/markmap-cli/bin/cli.js";

      gss = "git status --short";
      ga = "git add";
      gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
      gc = "git commit";
      gp = "git push";
      gu = "git pull";
      gl = "git log";
      gb = "git branch";
      gi = "git init";
      gcl = "git clone";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
