{ pkgs, ... }:

{
  imports = [
    ./home/starship.nix
    ./home/fish.nix
    ./home/ghostty.nix
    ./home/newsboat.nix
  ];
  # 注意修改这里的用户名与用户目录
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
    fastfetch
    tree
    stow
    starship
    neovim
    emacs
    nushell
    bat

    # gnu
    ed
    gnumake
    gnused
    gnutar
    gawk
    gnupg

    git
    gh
    ripgrep
    pandoc
    texlive.combined.scheme-full
    cmake
    dig
    fd

    # misc
    cowsay
    file
    which
    bc

    # gui apps
    kitty
    ghostty
    wechat-uos
    neovide
    zed-editor
    vscode
    qbittorrent
    anki
    zotero
    obs-studio
    wineWayland

    ## docs
    libreoffice
    papers
    wpsoffice-cn

    ## email
    thunderbird
    kdePackages.kmail
    # geary

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
    pywalfox-native

    # pdf reader
    zathura
    sioyek

    # reverse engineering, learn it some day!
    ghidra

    # processing software
    # davinci-resolve
    gimp
    bitwig-studio5-unwrapped
    jre

    # rust
    cargo
    cargo-binstall

    chromium

    loupe

    # tui
    tmux
    htop
    w3m
    yazi
    fzf
    newsboat
    newsraft
    neomutt
    tokei
    lazygit
    gh-dash
    vhs
    glow
    glance

    # python
    poetry

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
    osdlyrics

    # video
    kdePackages.kdenlive
    inkscape-with-extensions # vector grahpics editor

    # sync
    rclone
    rclone-browser

    # ssh
    sshfs

    # utils
    pom
    pomodoro

    python311
    python311Packages.pygobject3

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

    # LSP and formatters
    zk
    rime-ls
    copilot-language-server
    translate-shell
    xmlstarlet

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

    # fun
    supercollider

    # compilers
    clang
    zig

    follow
    obsidian
    spotify

    # docker
    docker
    docker-compose

    # ladders
    clash-verge-rev
    flclash
    nekoray

    # nix
    nixd
    nixfmt-classic

    # lua
    luajit
    luarocks
    lua-language-server
    stylua
    luajitPackages.luacheck
    selene

    # c
    clang
    astyle

    # go
    go
    gopls

    # markdown
    markdownlint-cli2

    # archives
    zip
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq

    # file sync
    syncthing

    fractal
    webcord

    # widgets
    pw-volume
    networkmanagerapplet

    # nix related
    nix-output-monitor

    btop # replacement of htop/nmon
    iftop # network monitoring
    iotop # io monitoring

    # low level
    lshw
  ];

  # You can update Home Manager without changing this value.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
