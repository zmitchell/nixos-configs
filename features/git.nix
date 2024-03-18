{ ... }: {
  programs.git.config = {
    user = {
      name = "Zach Mitchell";
      email = "zmitchell@fastmail.com";
    };
    core = {
      # FIXME: some error with mkValueStringDefault
      # excludesfile = ../data/gitignore_global;
    };
    init = { defaultBranch = "main"; };
    commit = {
      # FIXME: some error with mkValueStringDefault
      # template = ../data/commit_template.txt;
      cleanup = "strip";
    };
    push = { autoSetupRemote = true; };
    pull = { ff = "only"; };
  };
}
