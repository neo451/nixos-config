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
        tokyo-night
      ];
  };

  # Emacs prefers ~/.emacs.d whenever that directory exists.  Link only the
  # init file there so existing mutable state such as eln-cache can stay put.
  home.file.".emacs.d/init.el".source = ./emacs/init.el;
}
