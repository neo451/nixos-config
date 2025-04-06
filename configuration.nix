# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      configurationLimit = 10;
      extraEntries = ''
        			menuentry "Windows" {
        				search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw/efi
        				chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
                                }
      '';
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  networking.hostName = "nixos"; # Define your hostname.

  time.timeZone = "Asia/Shanghai";

  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.overlays = [
    (final: prev: {
      librime = (prev.librime.override {
        plugins = [ pkgs.librime-lua pkgs.librime-octagram ];
      }).overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.luajit ]; # 用luajit
      });
    })
  ];

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      rime-data
      fcitx5-gtk
      kdePackages.fcitx5-qt
      fcitx5-rime
      fcitx5-nord
    ];
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
    ];
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "FiraCode Nerd Font" ];
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # TODO: Don't forget to set a password with ‘passwd’.
  users.users.n451 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      stow
      starship
      bat

      # gui apps
      ghostty
      zathura
      wechat-uos
      anki
      neovide
      libreoffice

      # tui
      yazi

      # music 
      qcm
      mpv
      vlc

      # productivity
      hugo # static site generator
      glow # markdown previewer in terminal

      # fun
      supercollider

      # need another source
      # follow
      # discord
      obsidian
      # spotify
      # inputs.zen-browser.packages."${system}".default

      # ladders
      mihomo-party
      clash-verge-rev
      #      hiddify-app
      nekoray

      # nix
      nixd
      nixfmt-classic

      # lua
      lua-language-server
      stylua

      # dependencies
      imagemagick
      tectonic
      sqlite
      mermaid-cli
      rime-ls
    ];
  };

  programs.neovim = { defaultEditor = true; };

  programs.git = {
    enable = true;
    config = {
      init = { defaultBranch = "main"; };
      user.name = "zizhou teng (n451)";
      user.email = "2020200706@ruc.edu.cn";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      cat = "bat";
    };
    shellAbbrs = {
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
    };
  };

  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    neovim
    xclip
    git
    gh
    ripgrep
    pandoc

    dig
    fzf
    fd

    fish

    # compilers
    clang
    zig
    luajit
  ];
  environment.variables.EDITOR = "nvim";

  nixpkgs.config = { allowUnfree = true; };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true; # TODO: enable this on the other laptop??

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "24.11"; # Did you read the comment?
}
