{
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      cat = "bat";
      em = "emacs -nw";
      ls = "exa -lah";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
