{
  description = "A simple NixOS flake";
  inputs.jj-starship.url = "github:dmmulroy/jj-starship";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell"; # add ?ref=<tag> to track a tag
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    nixpkgs,
    rust-overlay,
    neovim-nightly-overlay,
    home-manager,
    nur,
    nixos-wsl,
    jj-starship,
    ...
  } @ inputs: let
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};

      modules = [
        # inputs.musnix.nixosModules.musnix
        home-manager.nixosModules.home-manager
        nur.modules.nixos.default
        ./configuration.nix
        ({pkgs, ...}: {
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            neovim-nightly-overlay.overlays.default
            jj-starship.overlays.default
            (final: prev:
              let
                zoteroFirefox = prev.stdenvNoCC.mkDerivation {
                  pname = "firefox-esr-unwrapped";
                  version = "140.15.0esr";
                  src = prev.fetchurl {
                    url = "https://ftp.mozilla.org/pub/firefox/releases/140.15.0esr/linux-x86_64/en-US/firefox-140.15.0esr.tar.xz";
                    hash = "sha256-yTquYQ8Rd9962ngjve9DPe1P9r/k5rrtppQav06ZLz8=";
                  };
                  dontBuild = true;
                  installPhase = ''
                    mkdir -p $out/lib
                    cp -r . $out/lib/firefox
                  '';
                };
              in {
              vcv-rack = prev.vcv-rack.overrideAttrs (old: {
                # Upstream GitHub PR pages can 404 while patch-diff still serves
                # the same patch; keep nixpkgs' expected normalized hash.
                patches =
                  builtins.filter
                  (patch: !(final.lib.hasInfix "fix-segfault-on-linux.patch" (toString patch)))
                  (old.patches or [])
                  ++ [
                    (prev.fetchpatch {
                      name = "fix-segfault-on-linux.patch";
                      url = "https://patch-diff.githubusercontent.com/raw/VCVRack/Rack/pull/1944.patch";
                      hash = "sha256-dlndyCfCznGDzlWNWrQTgh+FtmsrrL2DVuRE0xCxUck=";
                    })
                  ];
              });

              # GitHub regenerated the v1.63.0 archive without changing the tag.
              # Keep the package buildable until nixpkgs updates its fixed-output hash.
              python313Packages = prev.python313Packages.overrideScope (pyFinal: pyPrev: {
                playwright = pyPrev.playwright.overrideAttrs (old: {
                  src = prev.fetchFromGitHub {
                    owner = "microsoft";
                    repo = "playwright-python";
                    rev = "v1.63.0";
                    hash = "sha256-RwIn+0EcHnStjORVFmT7gp4bGjl+qer1FgtI3+aPF2w=";
                  };
                });
              });

              # Zotero 10.0.4 patches Firefox ESR 140, not the newer ESR 153.
              zotero = prev.zotero.override {
                firefox-esr-153-unwrapped = zoteroFirefox;
              };

              ly = prev.ly.overrideAttrs (old: {
                # Make postPatch's `ln -s ... $ZIG_GLOBAL_CACHE_DIR/p` not explode
                prePatch =
                  (old.prePatch or "")
                  + ''
                    export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/zig-global-cache-initial"
                    mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
                  '';

                # After old.postPatch ran, remember where that /p link points.
                postPatch =
                  (old.postPatch or "")
                  + ''
                    if [ -e "$ZIG_GLOBAL_CACHE_DIR/p" ]; then
                      export _ly_zig_pkgs_target="$(readlink -f "$ZIG_GLOBAL_CACHE_DIR/p")"
                    fi
                  '';

                # zig.hook may reset ZIG_GLOBAL_CACHE_DIR later; ensure /p exists in the *final* cache dir
                preBuild =
                  (old.preBuild or "")
                  + ''
                    if [ -n "''${_ly_zig_pkgs_target:-}" ]; then
                      mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
                      ln -sf "$_ly_zig_pkgs_target" "$ZIG_GLOBAL_CACHE_DIR/p"
                    fi
                  '';
              });
            })
          ];
        })
      ];
    };

    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};

      modules = [
        nixos-wsl.nixosModules.default
        home-manager.nixosModules.home-manager
        ./modules/shared.nix
        ./hosts/wsl
        ({...}: {
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            neovim-nightly-overlay.overlays.default
            jj-starship.overlays.default
          ];
        })
      ];
    };
  };
}
