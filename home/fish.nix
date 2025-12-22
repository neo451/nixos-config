{
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      timer = "~/bin/timer";
      pp = "~/scripts/wp";
      cat = "bat";
    };
    shellInit = ''
      fish_add_path ~/.npm-global/bin
      if test -f ~/.config/private-env
        source ~/.config/private-env
      end
      fish_add_path ~/Clone/emmylua-analyzer-rust/target/release/
      fish_add_path ~/bin/
      if test -f ~/secret/AI.fish
          source ~/secret/AI.fish
      end
    '';
    shellAbbrs = {
      nfu = "cd ~/nixos-config; sudo nix flake update";
      nrs = "~/scripts/rebuild-os";
      pushn = "~/scripts/push-notes";
      gss = "git status --short";
      ga = "git add";
      gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
      gc = "git commit";
      gp = "git push";
      gP = "git pull";
      gl = "git log";
      gb = "git branch";
      gi = "git init";
      gcl = "git clone";
      em = "emacs -nw";
    };
  };
}
