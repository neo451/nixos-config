{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  isWsl = lib.attrByPath ["wsl" "enable"] false config;
in {
  nix.settings = {
    download-buffer-size = 536870912; # 512 MiB
    substituters = [];
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.overlays = [
    (final: prev: {
      librime =
        (prev.librime.override {
          plugins = [pkgs.librime-lua pkgs.librime-octagram];
        }).overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [pkgs.luajit];
        });
    })
  ];

  environment.variables = {
    EDITOR = "nvim";
    RIME_DATA_DIR = "${pkgs.rime-data}/share/rime-data";
    LLAMA_BASE_URL = "http://127.0.0.1:8080";
  };

  systemd.tmpfiles.rules = [
    "d /home/n451/models 0755 n451 users -"
  ];

  systemd.services.llama-server = {
    description = "llama.cpp router server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      ExecStart = "${pkgs.llama-cpp}/bin/llama-server --models-dir /home/n451/models --no-models-autoload --jinja --host 127.0.0.1 --port 8080";
      Restart = "on-failure";
      RestartSec = 5;
      User = "n451";
      Group = "users";
    };
  };

  users.users.n451 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "docker" "input" "audio" "realtime"];
  };

  users.groups.realtime = {};

  programs.fish.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    config = {
      init = {defaultBranch = "main";};
      user.name = "zizhou teng (n451)";
      user.email = "2020200706@ruc.edu.cn";
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
    ];
  };

  # Run the Docker daemon on startup on both bare-metal NixOS and WSL.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkIf (!isWsl) "btrfs";
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-36.9.5"
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = inputs;
  home-manager.backupFileExtension = "backup";
  home-manager.users.n451 = {
    imports =
      [
        ../cmdline.nix
        ../home/rime.nix
      ]
      ++ lib.optionals (!isWsl) [
        inputs.caelestia-shell.homeManagerModules.default
        ../home.nix
      ];
    home.username = "n451";
    home.homeDirectory = "/home/n451";
    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    rust-bin.stable.latest.default
  ];
}
