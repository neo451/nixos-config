{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./home/ghostty.nix
  ];
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "x-scheme-handler/obsidian" = "obsidian-nvim.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "text/html" = "zen-beta.desktop";
    };
  };

  xdg.desktopEntries.obsidian-nvim = {
    name = "obsidian.nvim";
    comment = "Handle obsidian:// URIs in Neovim with obsidian.nvim";
    exec = "obsidian-uri-handler %u";
    terminal = true;
    type = "Application";
    noDisplay = true;
    mimeType = ["x-scheme-handler/obsidian"];
    categories = ["Utility" "TextEditor"];
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  home.packages = with pkgs; [
    # pi
    rpi-imager

    chromium

    # bluetooth
    blueman
    adw-bluetooth

    # presentation
    sent

    # writing
    libreoffice-fresh
    papers
    # wpsoffice-cn

    webcord

    thunderbird

    # gui apps
    kitty
    ghostty
    wechat-uos
    zotero
    zed-editor
    loupe
    anki
    karere
    wine-wayland
    steam-run
    obsidian
    calibre
    # tor-browser
    wireshark

    # video
    obs-studio # screen recording

    ## display manager
    ly

    # hyprland
    waybar # bar
    eww # widget sustem
    app2unit # launch notification links/actions from Caelestia
    libnotify # notify-send client; Caelestia owns the daemon
    xdg-utils # xdg-mime for app2unit URL handling
    hyprshot
    wl-clipboard # copy & paste
    rofi # app launcher
    hyprlock

    # suckless
    dmenu-wayland

    # wallpaper
    pywal16
    awww # wallpaper daemon

    # pdf reader
    zathura
    sioyek

    # audio and video
    mpv
    vlc
    pipewire
    spotify

    # processing software
    # davinci-resolve
    gimp
    supercollider
    mgba # gameboy!
    vcv-rack
    # jre
    # bitwig-studio
    # kdePackages.kdenlive # video
    # inkscape-with-extensions # vector grahpics editor

    # download
    qbittorrent # download

    # ladders
    # clash-verge-rev
    # nekoray

    # widgets
    networkmanagerapplet
  ];

  # https://github.com/caelestia-dots/shell
  programs.caelestia = {
    enable = true;
    systemd.enable = true;
    systemd.environment = [
      "PATH=${lib.makeBinPath [pkgs.app2unit pkgs.libnotify pkgs.systemd pkgs.xdg-utils]}:/etc/profiles/per-user/n451/bin:/run/current-system/sw/bin"
    ];
    cli.enable = true;
    settings = {
      notifs = {
        actionOnClick = true;
        openExpanded = true;
        expire = false;
        fullscreen = "on";
        defaultExpireTimeout = 7000;
        fullscreenExpireTimeout = 3000;
        groupPreviewNum = 3;
      };
      services = {
        lyricsBackend = "Auto";
        showLyrics = false;
      };
    };
  };
}
