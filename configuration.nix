{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix];
  musnix = {
    enable = false;
    kernel.realtime = false;
  };
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
    ];
    experimental-features = ["nix-command" "flakes"];
  };

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

  nixpkgs.overlays = [
    (final: prev: {
      librime =
        (prev.librime.override {
          plugins = [pkgs.librime-lua pkgs.librime-octagram];
        }).overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [pkgs.luajit]; # 用luajit
        });
    })
  ];

  environment.variables = {
    "RIME_DATA_DIR" = "${pkgs.rime-data}/share/rime-data";
  };

  i18n.defaultLocale = "en_US.UTF-8";

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
        emoji = ["Noto Color Emoji"];
        monospace = ["FiraCode Nerd Font"];
        sansSerif = ["Noto Sans CJK SC"];
        serif = ["Noto Serif CJK SC"];
      };
    };
  };

  environment.sessionVariables = {NIXOS_OZONE_WL = "1";};

  hardware.bluetooth.enable = true;

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

  services = {xserver = {videoDrivers = ["nvidia"];};};

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

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  users.users.n451 = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "input" "audio" "realtime"];
  };

  users.groups.realtime = {};

  programs.neovim = {defaultEditor = true;};

  programs.git = {
    enable = true;
    config = {
      init = {defaultBranch = "main";};
      user.name = "zizhou teng (n451)";
      user.email = "2020200706@ruc.edu.cn";
    };
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages."${system}".default
  ];

  environment.variables.EDITOR = "nvim";

  nixpkgs.config = {allowUnfree = true;};

  # Enable the OpenSSH daemon.
  services.openssh.enable = true; # TODO: enable this on the other laptop??

  system.stateVersion = "24.11"; # Did you read the comment?
}
