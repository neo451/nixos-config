{
  lib,
  pkgs,
  ...
}: let
  davinciResolveNvidia = pkgs.callPackage "${pkgs.path}/pkgs/by-name/da/davinci-resolve/package.nix" {
    # Resolve's CUDA device and OpenGL viewer must use the same GPU. This
    # laptop's display is wired to Intel, so force Resolve through NVIDIA PRIME.
    buildFHSEnv = args:
      pkgs.buildFHSEnv (args // {
        extraBwrapArgs = (args.extraBwrapArgs or []) ++ [
          "--setenv" "__NV_PRIME_RENDER_OFFLOAD" "1"
          "--setenv" "__GLX_VENDOR_LIBRARY_NAME" "nvidia"
          # Resolve does not currently work with native Wayland.
          "--setenv" "QT_QPA_PLATFORM" "xcb"
          "--setenv" "QT_XCB_GL_INTEGRATION" "glx"
        ];
      });
  };
  caelestiaShellSettings = {
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
    };
  };
in {
  imports = [
    ./home/ghostty.nix
  ];
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      # "x-scheme-handler/obsidian" = "obsidian-nvim.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "text/html" = "zen-beta.desktop";
    };
  };

  # xdg.desktopEntries.obsidian-nvim = {
  #   name = "obsidian.nvim";
  #   comment = "Handle obsidian:// URIs in Neovim with obsidian.nvim";
  #   exec = "obsidian-uri-handler %u";
  #   terminal = true;
  #   type = "Application";
  #   noDisplay = true;
  #   mimeType = ["x-scheme-handler/obsidian"];
  #   categories = ["Utility" "TextEditor"];
  # };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  # Hyprland is started outside systemd's graphical-session.target, so the
  # Home Manager default target would otherwise never start udiskie.
  systemd.user.services.udiskie.Install.WantedBy = lib.mkForce ["default.target"];

  home.packages = with pkgs; [
    # gui
    zathura

    # browser
    firefox
    chromium

    # pi
    rpi-imager

    # bluetooth
    blueman
    adw-bluetooth

    # presentation
    sent

    # writing
    libreoffice-stable
    papers
    # wpsoffice-cn

    webcord

    thunderbird

    # gui apps
    kitty
    ghostty
    wechat-uos
    qq
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
    davinciResolveNvidia
    audacity
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
    clash-verge-rev
    throne

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
    # `settings` is deliberately not used: it generates
    # ~/.config/caelestia/shell.json as a read-only symlink into the Nix store,
    # and Caelestia writes that file back at runtime, producing a
    # "Failed to save config" toast on startup. Seed a writable file below.
  };

  home.activation.seedCaelestiaConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "$HOME/.config/caelestia"

    # Replace a store symlink (from a previous `settings`-based config) with a real file.
    if [ -L "$HOME/.config/caelestia/shell.json" ]; then
      run rm "$HOME/.config/caelestia/shell.json"
    fi

    # Only seed if missing so runtime changes made by the shell are preserved.
    if [ ! -e "$HOME/.config/caelestia/shell.json" ]; then
      run cp ${pkgs.writeText "caelestia-shell.json" (builtins.toJSON caelestiaShellSettings)} "$HOME/.config/caelestia/shell.json"
    fi
  '';
}
