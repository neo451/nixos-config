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

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.overlays = [
    (final: prev: {
      librime =
        (prev.librime.override {
          plugins = [pkgs.librime-lua pkgs.librime-octagram];
        }).overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [pkgs.luajit];
        });
      owl = prev.owl.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            sed -i '1i #include <cstdint>' googletest/googletest/src/gtest-death-test.cc
            sed -i '1i #include <cstdint>' googletest/googletest/include/gtest/internal/gtest-port.h
          '';
      });
    })
  ];

  environment.variables = {
    EDITOR = "nvim";
    RIME_DATA_DIR = "${pkgs.rime-data}/share/rime-data";
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
