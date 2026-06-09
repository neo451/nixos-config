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

  # Windows Cursor/VS Code WSL installers run non-login shells where NixOS
  # profile setup is not sourced. Put the basic tools they call on /bin so
  # probes like `uname -m` do not resolve to an empty platform/arch.
  wsl.extraBin = let
    b = pkg: name: {src = "${pkg}/bin/${name}";};
  in
    with pkgs; [
      (b coreutils-full "uname")
      (b coreutils-full "mkdir")
      (b coreutils-full "rm")
      (b coreutils-full "cat")
      (b coreutils-full "chmod")
      (b coreutils-full "touch")
      (b coreutils-full "ln")
      (b coreutils-full "mv")
      (b coreutils-full "cp")
      (b coreutils-full "sleep")
      (b coreutils-full "date")
      (b coreutils-full "dirname")
      (b coreutils-full "basename")
      (b coreutils-full "id")
      (b coreutils-full "whoami")
      (b coreutils-full "mktemp")
      (b coreutils-full "tr")
      (b coreutils-full "cut")
      (b coreutils-full "sort")
      (b coreutils-full "head")
      (b coreutils-full "tail")
      (b coreutils-full "wc")
      (b coreutils-full "ls")
      (b coreutils-full "readlink")
      (b coreutils-full "realpath")
      (b coreutils-full "tee")
      (b coreutils-full "env")
      (b coreutils-full "true")
      (b coreutils-full "false")
      (b gnugrep "grep")
      (b gnused "sed")
      (b gawk "awk")
      (b gnutar "tar")
      (b gzip "gzip")
      (b gzip "gunzip")
      (b gzip "zcat")
      (b xz "xz")
      (b xz "unxz")
      (b findutils "find")
      (b findutils "xargs")
      (b procps "ps")
      (b procps "pgrep")
      (b procps "pkill")
      (b curl "curl")
      (b wget "wget")
      (b which "which")
    ];

  # stateVersion is PER-HOST. Do NOT copy the bare-metal value.
  # Replace this with the value the NixOS-WSL installer wrote into
  # /etc/nixos/configuration.nix on first boot.
  system.stateVersion = "25.11";
}
