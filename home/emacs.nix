{
  config,
  lib,
  pkgs,
  ...
}: {
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

  # Seed editable Org files into ~/orgfiles on first activation.  They are
  # copied only when missing, so later rebuilds will not overwrite your notes.
  home.activation.seedOrgfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    orgdir="${config.home.homeDirectory}/orgfiles"
    mkdir -p "$orgdir"

    for file in agenda.org guide.org; do
      if [ ! -e "$orgdir/$file" ]; then
        install -m 0644 "${./orgfiles}/$file" "$orgdir/$file"
      fi
    done
  '';
}
