{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./home/starship.nix
    ./home/fish.nix
    ./home/ghostty.nix
    ./home/newsboat.nix
    ./home/atuin.nix
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

  home.username = "n451";
  home.homeDirectory = "/home/n451";

  # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  home.file."scripts" = {
    source = ./scripts;
    recursive = true; # 递归整个文件夹
    executable = true; # 将其中所有文件添加「执行」权限
  };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.sessionVariables = {
    REF = "/home/n451/Documents/refs.bib";
  };

  accounts.email.accounts = {
    "k24098496@kcl.ac.uk" = {
      primary = true;
      address = "k24098496@kcl.ac.uk";
      userName = "Zizhou Teng";
      realName = "Zizhou Teng";

      imap.host = "outlook.office365.com";
      smtp.host = "smtp.office365.com";

      neomutt = {
        enable = true;
      };
    };
  };

  programs.neomutt = {
    enable = true;
  };

  home.packages = with pkgs; [
    neovim
    emacs
    cmake

    vim
    wget

    git
    jujutsu
    lazygit
    lazyjj
    gh
    gh-dash

    # life
    hledger

    # pi
    rpi-imager

    chromium

    # ocr
    tesseract

    # ai
    opencode
    codex
    pi-coding-agent
    claude-code
    claude-agent-acp
    llama-cpp
    cursor-cli
    copilot-language-server

    brightnessctl # brightness control
    udisks # usb disks

    ## bluetooth
    blueman
    adw-bluetooth

    ## presentation

    slides
    sent
    marp-cli
    # presentterm

    # writing
    write-good
    quarto
    typst
    libreoffice-fresh
    papers
    # wpsoffice-cn
    pandoc
    texliveFull
    zk
    rime-ls
    translate-shell
    marksman
    qpdf
    iwe

    webcord

    ## notebook
    # marimo
    uv
    ruff

    thunderbird

    # life utils
    pom
    pomodoro

    # cmdline
    starship
    bat
    tree
    dust
    ncdu
    tldr
    zoxide
    nushell
    eza

    ## shell
    fish
    xonsh
    atuin
    shellcheck

    # file
    ripgrep
    fd
    fzf
    file
    jq
    yq
    yazi

    # gnu
    ed
    gnumake
    gnused
    gnutar
    gawk
    gnupg

    # network
    dig
    iftop # network monitoring
    netcat
    openssl
    chrony
    websocat
    wireshark
    owl #  Apple Wireless Direct Link (AWDL) for opendrop
    iw
    wormhole-rs
    inetutils
    nmap
    mtr

    btop # replacement of htop/nmon
    iotop # io monitoring
    powertop # battery monitor TODO

    which
    bc
    zip
    unzip

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
    obsidian
    calibre

    qutebrowser

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

    # tui
    tmux
    htop
    w3m
    yazi
    tokei
    vhs
    neomutt
    glow

    # audio & video
    yt-dlp
    ffmpeg
    go-musicfox
    mpv
    vlc
    sox
    playerctl
    rmpc
    mpd
    mpc
    pipewire
    spotify

    # processing software
    # davinci-resolve
    gimp
    supercollider
    mgba # gameboy!
    # jre
    bitwig-studio
    # kdePackages.kdenlive # video
    # inkscape-with-extensions # vector grahpics editor

    # sync
    rsync
    rclone
    # rclone-browser
    syncthing
    qbittorrent # download
    opendrop # airdrop

    # ssh
    sshfs

    # js
    yarn
    nodejs
    deno
    prettier

    # docker
    docker
    docker-compose

    # ladders
    # clash-verge-rev
    # nekoray

    # widgets
    networkmanagerapplet

    # nix related
    nix-output-monitor

    # dependencies
    ghostscript
    imagemagick
    sqlite
    mermaid-cli
    diff-so-fancy
    wordnet
    harper
    kulala-fmt
    typos

    # lua
    # luajit
    luarocks
    lua5_1

    lua-language-server
    stylua
    luajitPackages.luacheck
    selene
    luajitPackages.busted
    luajitPackages.luacov
    emmylua-ls
    emmylua-check
    emmylua-doc-cli

    ## python
    python3
    pyright
    ruff
    black
    python313Packages.playwright
    python313Packages.pydbus

    ## js
    typescript-language-server

    # go
    go
    gopls

    # nix
    nixd
    alejandra

    # rust
    cargo

    # compilers
    clang

    # zig
    zig
    # zls

    readline
    lsof
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

  # You can update Home Manager without changing this value.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
