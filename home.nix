{pkgs, ...}: {
  imports = [
    ./home/starship.nix
    ./home/fish.nix
    ./home/ghostty.nix
    ./home/newsboat.nix
  ];

  home.username = "n451";
  home.homeDirectory = "/home/n451";

  # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # 递归整个文件夹
  #   executable = true;  # 将其中所有文件添加「执行」权限
  # };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  home.sessionPath = ["$HOME/.cargo/bin"];

  home.sessionVariables = {
    REF = "/home/n451/Documents/refs.bib";
  };

  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
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
    git
    gh
    vim
    wget

    brightnessctl # brightness control
    udisks # usb disks

    ## bluetooth
    blueman

    # writing
    write-good
    quarto
    mpls

    (llm.withPlugins
      {
        llm-deepseek = true;
        # llm-ollama = true;
      })

    ladybird

    # ollama-cuda

    thunderbird

    # life utils
    pom
    pomodoro

    # cmdline
    starship
    fish
    bat
    tree
    atuin
    dust
    tldr

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
    qq
    qqmusic
    zotero
    obsidian
    zed-editor
    vscode # vs **
    qbittorrent # download
    webcord # discord
    chromium
    loupe
    anki
    # wine-wayland
    # neovide

    # video
    obs-studio # screen recording

    # game
    love

    ## display manager
    ly

    # hyprland
    waybar # bar
    eww # widget sustem
    dunst # notification daemon
    libnotify
    hyprshot
    wl-clipboard # copy & paste
    rofi # app launcher
    hyprlock

    # suckless
    dmenu-wayland

    # wallpaper
    pywal16
    swww # wallpaper daemon

    # pdf reader
    zathura
    sioyek

    # reverse engineering, learn it some day!
    ghidra

    ## docs
    libreoffice
    papers
    wpsoffice-cn
    pandoc
    texliveFull

    # tui
    tmux
    htop
    w3m
    yazi
    tokei
    vhs
    gh-dash
    glance
    neomutt
    lazygit
    glow

    ## rss
    # newsboat
    # newsraft

    # jupyter-notebook
    jupyter-all

    # python313Packages.dbus-python

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
    davinci-resolve
    gimp
    # jre
    # bitwig-studio
    # vcv-rack
    # kdePackages.kdenlive # video
    # inkscape-with-extensions # vector grahpics editor
    supercollider

    # sync
    rsync
    rclone
    rclone-browser
    syncthing

    # ssh
    sshfs

    # LSP and formatters
    zk
    rime-ls
    translate-shell

    # js
    yarn
    nodejs
    deno
    nodePackages_latest.neovim

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
    nodePackages.prettier
    kulala-fmt
    typos
    tree-sitter
    copilot-language-server

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

    # c
    clang

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
    zls

    # lisp
    clojure-lsp
    clojure

    elixir
    elixir-ls
    livebook

    readline

    lsof
  ];

  # You can update Home Manager without changing this value.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
