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

      gs = "git status --short";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
