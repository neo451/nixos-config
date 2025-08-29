{ pkgs, ... }:

{
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

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  home.packages = with pkgs; [
    neovim
    starship
    emacs
    cmake
    git
    gh
    ripgrep
    pandoc

    nushell
    # bat
    # tree

    # gnu
    ed
    gnumake
    gnused
    gnutar
    gawk
    gnupg

    dig
    fd
    file
    which
    bc
    zip
    unzip

    # gui apps
    kitty
    ghostty
    wechat-uos
    anki
    zotero
    obsidian
    wineWayland
    neovide
    zed-editor
    vscode # vs **
    qbittorrent # download
    obs-studio # screen recording
    webcord # discord
    chromium
    loupe

    # game
    love

    ## ai
    llm

    ## display manager
    ly

    # hyprland
    waybar # bar
    eww # widget sustem
    dunst # notification daemon
    libnotify
    hyprshot
    wl-clipboard # copy & paste
    rofi-wayland # app launcher
    hyprlock

    # suckless
    dmenu-wayland

    # wallpaper
    pywal16
    swww # wallpaper daemon

    # pdf reader
    # zathura
    # sioyek

    # reverse engineering, learn it some day!
    ghidra

    ## docs
    libreoffice
    papers
    wpsoffice-cn

    # tui
    tmux
    htop
    w3m
    yazi
    fzf
    tokei
    vhs
    gh-dash
    newsboat
    newsraft
    neomutt
    lazygit
    glow
    glance
    atuin

    # python
    poetry
    jupyter-all
    python312Packages.jupytext

    # audio & video
    yt-dlp
    ffmpeg
    go-musicfox
    splayer
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
    jre
    bitwig-studio
    vcv-rack
    kdePackages.kdenlive # video
    inkscape-with-extensions # vector grahpics editor
    supercollider

    # sync
    rsync
    rclone
    rclone-browser
    syncthing

    # ssh
    sshfs

    # utils
    pom
    pomodoro

    # LSP and formatters
    zk
    rime-ls
    translate-shell

    # js
    yarn
    nodejs
    deno

    # zig
    zig
    zls

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    # docker
    docker
    docker-compose

    # ladders
    clash-verge-rev
    flclash
    # nekoray

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq

    # widgets
    networkmanagerapplet

    # nix related
    nix-output-monitor

    btop # replacement of htop/nmon
    iftop # network monitoring
    iotop # io monitoring

    # dependencies
    ghostscript
    imagemagick
    tectonic
    sqlite
    mermaid-cli
    diff-so-fancy
    wordnet
    harper
    nodePackages.prettier
    kulala-fmt
    tree-sitter
    copilot-language-server

    # lua
    luajit
    luarocks
    lua-language-server
    stylua
    luajitPackages.luacheck
    selene
    luajitPackages.busted
    luajitPackages.luacov

    # c
    clang
    astyle

    # go
    go
    gopls

    # markdown
    markdownlint-cli2

    # nix
    nixd
    nixfmt-classic

    # rust
    cargo
    cargo-binstall

    # compilers
    clang
    zig
  ];

  # You can update Home Manager without changing this value.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
