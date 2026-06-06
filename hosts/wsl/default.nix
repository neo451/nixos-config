{
  lib,
  pkgs,
  ...
}: {
  wsl = {
    enable = true;

    # MUST match the user the WSL installer created (and the shared user account).
    defaultUser = "n451";

    # Headless: no Start Menu shortcuts for GUI apps.
    startMenuLaunchers = false;

    # GPU passthrough off (default). Leave false for headless.
    # useWindowsDriver = false;

    wslConf = {
      automount.root = "/mnt";
      # Keep the Windows PATH out of the Linux shell: faster, avoids binary shadowing.
      interop.appendWindowsPath = false;
      # Leave resolv.conf / hosts generation at defaults unless using a custom DNS/VPN.
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;
    loadModels = ["nomic-embed-text"];
  };

  environment.systemPackages = with pkgs; [
    wsl-open
  ];

  # stateVersion is PER-HOST. Do NOT copy the bare-metal value.
  # Replace this with the value the NixOS-WSL installer wrote into
  # /etc/nixos/configuration.nix on first boot.
  system.stateVersion = "25.11";
}
