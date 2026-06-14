{config, lib, pkgs, user, ...}:
{
  config = {
    home.username = user.username;

    # Use my editor of choice everywhere.
    # There's a bug for these options: https://github.com/nix-community/home-manager/issues/3417
    home.sessionVariables.EDITOR = "hx";
    home.sessionVariables.GIT_EDITOR = "hx";

    # Common tools
    programs.jq.enable = true;
    programs.less.enable = true;
    programs.man.enable = true;
    programs.eza.enable = true;
    programs.yazi = {
      enable = true;
      settings.mgr = {
        linemode = "permissions";
        show_hidden = true;
      };
    };
  };
}
