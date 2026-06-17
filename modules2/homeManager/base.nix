{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      # Use my editor of choice everywhere.
      # There's a bug for these options: https://github.com/nix-community/home-manager/issues/3417
      home.sessionVariables.EDITOR = "hx";
      home.sessionVariables.GIT_EDITOR = "hx";

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

      home.packages = with pkgs; [
        bat
        fd
        file
        frogmouth
        fx
        nix-tree
        nixfmt
        pyright
        ripgrep
        tealdeer
        tomlq
        tre-command
        unstable.nil
        unstable.nixd
        unzip
        watchexec
      ];
    };
}
