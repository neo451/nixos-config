{pkgs, ...}: {
  imports = [
    ./home/starship.nix
    ./home/fish.nix
    ./home/newsboat.nix
    ./home/atuin.nix
    ./home/emacs.nix
  ];

  home.file."scripts" = {
    source = ./scripts;
    recursive = true;
    executable = true;
  };

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

    # ocr
    tesseract

    # ai
    opencode
    codex
    claude-code
    # claude-agent-acp
    llama-cpp
    cursor-cli
    copilot-language-server
    pi-coding-agent

    brightnessctl
    udisks

    # presentation
    slides
    marp-cli
    # presentterm

    # writing
    write-good
    quarto
    typst
    pandoc
    texliveFull
    zk
    rime-ls
    translate-shell
    marksman
    qpdf
    iwe

    # notebook
    # marimo
    uv
    ruff

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

    # shell
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

    tree-sitter

    # gnu
    ed
    gnumake
    gnused
    gnutar
    gawk
    gnupg

    # network
    dig
    iftop
    netcat
    openssl
    chrony
    websocat
    owl
    iw
    wormhole-rs
    inetutils
    nmap
    mtr

    btop
    iotop
    powertop

    which
    bc
    zip
    unzip

    # tui
    tmux
    htop
    w3m
    tokei
    vhs
    neomutt
    glow

    # audio and video cli
    yt-dlp
    ffmpeg
    go-musicfox
    sox
    playerctl
    rmpc
    mpd
    mpc

    # sync
    rsync
    rclone
    syncthing
    opendrop

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

    # nix
    nix-output-monitor
    nixd
    alejandra

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

    # python
    python3
    pyright
    black
    python313Packages.playwright
    python313Packages.pydbus

    # js
    typescript-language-server

    # go
    go
    gopls

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
}
