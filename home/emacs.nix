{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;

    extraPackages = epkgs:
      with epkgs; [
        evil
        evil-collection
        evil-org
        evil-surround
        which-key
      ];
  };

  # Keep the Emacs configuration as plain text in this repo and link it into
  # ~/.config/emacs so it is easy to inspect while learning Org mode.
  xdg.configFile."emacs" = {
    source = ./emacs;
    recursive = true;
  };
}
