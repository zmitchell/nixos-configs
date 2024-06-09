{ lib, config, ... }: 
let
  cfg = config.git_config;
in
{
  options = {
    git_config.enable = lib.mkEnableOption "Configure global git settings";
  };

  config = {
    programs.git.config = lib.mkIf cfg.enable {
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
  };
}
