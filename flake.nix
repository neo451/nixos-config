{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nocodb = {
      url = "github:nocodb/nocodb";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    musnix.url = "github:musnix/musnix";
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
    # nixos-stable,
    rust-overlay,
    home-manager,
    nur,
    nocodb,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        inputs.musnix.nixosModules.musnix
        home-manager.nixosModules.home-manager
        nur.modules.nixos.default
        ./configuration.nix

        nocodb.nixosModules.nocodb
        {
          # Enable NocoDB
          services.nocodb.enable = true;
        }

        ({pkgs, ...}: {
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            inputs.neovim-nightly-overlay.overlays.default
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
