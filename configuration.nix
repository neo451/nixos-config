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
      configurationLimit = 2;
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

  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev;

    # TUN 推荐开启服务模式
    serviceMode = true;
    tunMode = true;

    # 可选
    autoStart = true;
  };

  # TUN 内核模块，一般可以自动加载，加上更保险
  boot.kernelModules = ["tun"];

  # TUN / Mihomo 和 rp_filter 容易冲突
  networking.firewall.checkReversePath = "loose";

  programs.throne = {
    enable = true;
    tunMode = {
      enable = true;
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    enableGtk2 = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      rime-data
      fcitx5-gtk
      kdePackages.fcitx5-qt
      fcitx5-rime
      fcitx5-rose-pine
      fcitx5-mozc
    ];
    fcitx5.settings.inputMethod = {
      "Groups/0" = {
        Name = "Default";
        "Default Layout" = "us";
        DefaultIM = "rime";
      };
      "Groups/0/Items/0" = {
        Name = "keyboard-us";
        Layout = "";
      };
      "Groups/0/Items/1" = {
        Name = "rime";
        Layout = "";
      };
      "Groups/0/Items/2" = {
        Name = "mozc";
        Layout = "";
      };
      GroupOrder."0" = "Default";
    };
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

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  # Keep large C++/Qt builds (e.g. quickshell) from exhausting the sandbox /build tmpdir.
  # The previous generated nix.conf used max-jobs=auto and cores=0, which can fan out
  # too many compiler jobs at once.
  nix.settings = {
    max-jobs = 2;
    cores = 4;
    substituters = [
      # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.cernet.edu.cn/nix-channels/store"
    ];
  };

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

  # The firmware write-protects the DDR5 SPD hub, so spd5118 fails its
  # resume callback with -ENXIO. Temperature monitoring is nonessential.
  boot.blacklistedKernelModules = ["spd5118"];

  # Avoid stale GuC command-transport state after s2idle resume. The internal
  # panel is driven by i915, and this failure coincides with the black screen.
  boot.kernelParams = ["i915.enable_guc=0"];

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

  # services.ollama = {
  #   enable = true;
  #   package = pkgs.ollama-cuda;
  #   loadModels = ["nomic-embed-text"];
  # };

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
