{ config, inputs, pkgs, ... }:

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

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    neofetch
    tree
    stow
    starship
    bat

    # gui apps
    ghostty
    zathura
    wechat-uos
    neovide
    nsxiv

    anki
    libreoffice
    zotero

    # tui
    yazi
    fzf
    newsboat
    newsraft
    neomutt

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

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    # fun
    supercollider

    xclip
    git
    gh
    ripgrep
    pandoc
    gnumake

    # shell utils
    dig
    fd

    # compilers
    clang
    zig
    luajit

    # need another source
    follow
    # discord
    obsidian
    # spotify

    # docker
    docker
    docker-compose

    # ladders
    flclash
    nekoray
    # clash-nyanpasu

    # nix
    nixd
    nixfmt-classic

    # lua
    lua-language-server
    stylua
    luajitPackages.luacheck

    # markdown
    markdownlint-cli2

    # archives
    zip
    # xz
    # unzip
    # p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor

    # # networking tools
    # mtr # A network diagnostic tool
    # iperf3
    # dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing
    # ipcalc # it is a calculator for the IPv4/v6 addresses
    #
    # # misc
    cowsay
    file
    which
    # gnused
    # gnutar
    # gawk
    # zstd
    # gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # btop # replacement of htop/nmon
    # iotop # io monitoring
    # iftop # network monitoring

    # system call monitoring
    # strace # system call monitoring
    # ltrace # library call monitoring
    # lsof # list open files
    #
    # # system tools
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
