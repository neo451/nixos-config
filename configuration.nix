{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./modules/shared.nix
  ];
  # musnix = {
  #   enable = false;
  #   kernel.realtime = false;
  # };
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      configurationLimit = 4;
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

  security.rtkit.enable = true; # allows real-time audio scheduling
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = 1;
    }
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];

  services.upower.enable = true;

  services.udisks2.enable = true;
  # services.gvfs.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "n451";
        security = "user";
      };
      share = {
        path = "/home/n451/share";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "n451";
      };
    };
  };

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      rime-data
      fcitx5-gtk
      kdePackages.fcitx5-qt
      fcitx5-rime
      fcitx5-rose-pine
      fcitx5-mozc
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      barlow
      nerd-fonts.fira-code
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      # noto-fonts-cjk-serif
      # noto-fonts-color-emoji
      corefonts
      vista-fonts
    ];
    fontconfig = {
      antialias = true;
      hinting.enable = true;
      # defaultFonts = {
      #   emoji = ["Noto Color Emoji"];
      #   monospace = ["FiraCode Nerd Font"];
      #   sansSerif = ["Noto Sans CJK SC"];
      #   serif = ["Noto Serif CJK SC"];
      # };
    };
  };

  environment.sessionVariables = {NIXOS_OZONE_WL = "1";};

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = false;
        KernelExperimental = false; # enables newer GATT handling
      };
    };
  };

  # Enable OpenGL
  hardware.graphics = {enable = true;};

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  services = {
    xserver = {videoDrivers = ["nvidia"];};
    blueman.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager = {
    ly = {
      enable = true;
      # wayland.enable = true;
    };
    defaultSession = "hyprland";
  };

  programs.firefox.enable = true;

  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true; # TODO: enable this on the other laptop??

  system.stateVersion = "24.11"; # Did you read the comment?
}
