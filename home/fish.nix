{
  programs.fish = {
    enable = true;
    shellAliases = {
      # vi = "nvim";
      cat = "bat";
      em = "emacs -nw";
      vi =
        "VIMRUNTIME=~/Clone/neovim/runtime ~/Clone/neovim/build/bin/nvim --luamod-dev";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
