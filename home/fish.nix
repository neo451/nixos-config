{
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      cat = "bat";
      em = "emacs -nw";
      mvi =
        "cd ~/Clone/neovim/ && VIMRUNTIME=./runtime ./build/bin/nvim --luamod-dev";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
