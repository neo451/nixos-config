{
  programs.git = {
    enable = true;

    extraConfig = {
      core = {
        compression = 9;
        whitespace = "error";
        preloadindex = true;
      };

      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };

      url."git@github.com:".insteadOf = "gh:";

      init.defaultBranch = "main";

      status = {
        branch = true;
        showStash = true; # 原文 showStatsh 应该是 typo
        showUntrackedFiles = "all";
      };

      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };

      pager.diff = "diff-so-fancy | $PAGER";

      diff-so-fancy.markEmptyLines = true;

      rebase.updateRefs = true;
    };
  };
}
