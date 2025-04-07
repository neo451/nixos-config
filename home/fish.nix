{
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      cat = "bat";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };
}
