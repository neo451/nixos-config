{
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      cat = "bat";
      em = "emacs -nw";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
