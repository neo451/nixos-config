{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-flake.url = "github:aodhanhayter/opencode-flake";

    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            (final: prev: {
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
          environment.systemPackages = [pkgs.rust-bin.stable.latest.default];
        })
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.n451 = {imports = [./home.nix];};
          home-manager.extraSpecialArgs = inputs;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
