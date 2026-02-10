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
    ...
  } @ inputs: let
    obsidianOverlay = final: prev: {
      obsidian = let
        version = "1.11.7";
        src = prev.fetchurl {
          url =
            if prev.stdenv.hostPlatform.isDarwin
            then "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/Obsidian-${version}.dmg"
            else "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
          hash =
            if prev.stdenv.hostPlatform.isDarwin
            then "sha256-TRE9ymNtpcp7gEbuuSfJxvYDXLDVNz+o4+RSNyHZgmE="
            else "sha256-HrqeFJ2C5uZw0IBtD9y607V6007fOwnA0KnA83cwWjg=";
        };
      in
        if prev.stdenv.hostPlatform.isDarwin
        then prev.obsidian.overrideAttrs (_: {inherit version src;})
        else
          prev.stdenv.mkDerivation {
            pname = "obsidian";
            inherit version src;
            inherit (prev.obsidian) icon desktopItem meta;
            nativeBuildInputs = [prev.makeWrapper prev.imagemagick];
            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin

              install -m 444 -D resources/app.asar $out/share/obsidian/app.asar
              install -m 444 -D resources/obsidian.asar $out/share/obsidian/obsidian.asar

              cat > $out/bin/obsidian << 'WRAPPER'
              #!${prev.bash}/bin/bash
              ELECTRON="${prev.electron}/bin/electron"
              APP_ASAR="$out/share/obsidian/app.asar"

              if pgrep -f "electron.*obsidian" > /dev/null 2>&1; then
                exec "$ELECTRON" "$APP_ASAR" "$@"
              else
                WAYLAND_FLAGS=""
                if [[ -n "$NIXOS_OZONE_WL" && -n "$WAYLAND_DISPLAY" ]]; then
                  WAYLAND_FLAGS="--ozone-platform=wayland"
                fi
                exec "$ELECTRON" $WAYLAND_FLAGS "$APP_ASAR" "$@"
              fi
              WRAPPER
              chmod +x $out/bin/obsidian

              substituteInPlace $out/bin/obsidian \
                --replace-fail '$out' "$out"

              install -m 444 -D "${prev.obsidian.desktopItem}/share/applications/"* \
                -t $out/share/applications/

              for size in 16 24 32 48 64 128 256 512; do
                mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
                magick -background none ${prev.obsidian.icon} -resize "$size"x"$size" \
                  $out/share/icons/hicolor/"$size"x"$size"/apps/obsidian.png
              done
              runHook postInstall
            '';
          };
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      nixpkgs.overlays = [obsidianOverlay];

      modules = [
        inputs.musnix.nixosModules.musnix
        home-manager.nixosModules.home-manager
        nur.modules.nixos.default
        ./configuration.nix
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
