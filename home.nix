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

  home.packages = with pkgs; [
    fastfetch
    tree
    stow
    starship
    bat

    # gui apps
    kitty
    ghostty
    zathura
    wechat-uos
    neovide
    nsxiv
    zed-editor
    vscode
    qbittorrent

    anki
    libreoffice
    zotero

    # tui
    w3m
    yazi
    fzf
    newsboat
    newsraft
    neomutt
    tokei

    # cli
    yt-dlp
    ffmpeg

    # music 
    qcm
    mpv
    vlc

    # dependencies
    imagemagick
    tectonic
    sqlite
    mermaid-cli
    rime-ls
    harper
    nodePackages.prettier
    claude-code
    translate-shell
    zk
    yarn
    marksman
    nodejs

    # zig
    zig
    zls

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    # fun
    supercollider

    git
    gh
    ripgrep
    pandoc
    texlive.combined.scheme-full
    gnumake
    cmake

    # shell utils
    dig
    fd

    # compilers
    clang
    zig

    # need another source
    follow
    # discord
    obsidian
    # spotify

    # docker
    docker
    docker-compose

    # ladders
    clash-verge-rev
    # clash-nyanpasu
    # flclash
    # nekoray

    # nix
    nixd
    nixfmt-classic

    # lua
    luajit
    luarocks
    lua-language-server
    stylua
    luajitPackages.luacheck

    # go
    go
    gopls

    # python
    python3

    # markdown
    markdownlint-cli2

    # archives
    zip
    unzip

    # xz
    # unzip
    # p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq
    fixjson

    # file sync
    syncthing

    # networking tools
    # mtr # A network diagnostic tool
    # iperf3
    # dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing
    # ipcalc # it is a calculator for the IPv4/v6 addresses
    #
    # misc
    cowsay
    file
    which
    gnused
    gnutar
    gawk

    # zstd
    gnupg

    # hyprland
    waybar # bar
    # eww # widget sustem
    dunst # notification daemon
    libnotify

    # copy & paste
    wl-clipboard

    # desktop portal?

    swww # wallpaper daemon
    hyprshot

    # app launcher
    rofi-wayland

    # widgets
    pw-volume
    networkmanagerapplet

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    btop # replacement of htop/nmon
    iftop # network monitoring
    # iotop # io monitoring

    tree-sitter

    # system call monitoring
    # strace # system call monitoring
    # ltrace # library call monitoring
    # lsof # list open files

    # system tools
    # sysstat
    # lm_sensors # for `sensors` command
    # ethtool
    # pciutils # lspci
    # usbutils # lsusb
  ];

  # You can update Home Manager without changing this value.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
