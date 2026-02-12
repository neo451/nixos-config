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
    obsidianOverlay = self: super: {
      obsidian = let
        version = "1.11.7";
        src = super.fetchurl {
          url =
            if super.stdenv.hostPlatform.isDarwin
            then "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/Obsidian-${version}.dmg"
            else "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
          hash =
            if super.stdenv.hostPlatform.isDarwin
            then "sha256-TRE9ymNtpcp7gEbuuSfJxvYDXLDVNz+o4+RSNyHZgmE="
            else "sha256-HrqeFJ2C5uZw0IBtD9y607V6007fOwnA0KnA83cwWjg=";
        };
      in
        if super.stdenv.hostPlatform.isDarwin
        then
          super.obsidian.overrideAttrs (oldAttrs: {
            inherit version src;
          })
        else
          # Linux: rebuild with wrapper that properly handles CLI
          # The app.asar contains Electron's single-instance logic which routes CLI to running instance
          super.stdenv.mkDerivation {
            pname = "obsidian";
            inherit version src;
            inherit (super.obsidian) icon desktopItem meta;
            nativeBuildInputs = [
              super.makeWrapper
              super.imagemagick
            ];
            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin

              install -m 444 -D resources/app.asar $out/share/obsidian/app.asar
              install -m 444 -D resources/obsidian.asar $out/share/obsidian/obsidian.asar

              # Smart wrapper that handles:
              # 1. Fresh launch (Obsidian not running): start with app.asar + Wayland flags
              # 2. CLI/TUI mode (Obsidian running): connect without Wayland flags
              #
              # When Obsidian is running, Electron's single-instance mechanism forwards args
              # to the existing process. Wayland flags get interpreted as CLI commands.
              cat > $out/bin/obsidian << 'WRAPPER'
              #!${super.bash}/bin/bash
              ELECTRON="${super.electron}/bin/electron"
              APP_ASAR="$out/share/obsidian/app.asar"

              # Check if Obsidian is already running (look for electron process with obsidian asar)
              if pgrep -f "electron.*obsidian" > /dev/null 2>&1; then
                # Obsidian is running: connect to existing instance (CLI/TUI mode)
                # No Wayland flags - they'd be forwarded to Obsidian CLI as commands
                exec "$ELECTRON" "$APP_ASAR" "$@"
              else
                # Obsidian not running: launch fresh instance with Wayland support
                WAYLAND_FLAGS=""
                if [[ -n "$NIXOS_OZONE_WL" && -n "$WAYLAND_DISPLAY" ]]; then
                  WAYLAND_FLAGS="--ozone-platform=wayland"
                fi
                exec "$ELECTRON" $WAYLAND_FLAGS "$APP_ASAR" "$@"
              fi
              WRAPPER
              chmod +x $out/bin/obsidian

              # Substitute the actual path
              substituteInPlace $out/bin/obsidian \
                --replace-fail '$out' "$out"

              install -m 444 -D "${super.obsidian.desktopItem}/share/applications/"* \
                -t $out/share/applications/

              for size in 16 24 32 48 64 128 256 512; do
                mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
                magick -background none ${super.obsidian.icon} -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/obsidian.png
              done
              runHook postInstall
            '';
          };
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};

      modules = [
        inputs.musnix.nixosModules.musnix
        home-manager.nixosModules.home-manager
        nur.modules.nixos.default
        ./configuration.nix
        ({pkgs, ...}: {
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            inputs.neovim-nightly-overlay.overlays.default
            obsidianOverlay
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
