{ pkgs, user, ... }:
let
  shellAliases = import ./shell-aliases.nix;
  deploy-config = pkgs.callPackage ../pkgs/deploy-config/default.nix { };
in
{
  imports = [
    ./common.nix
  ];

  home.stateVersion = "24.05";

  home.packages =
    with pkgs;
    [
      bacon
      utm
      lima
      colima
      docker-client
      docker-compose
    ]
    ++ [
      deploy-config
    ];

  # Same for Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    inherit shellAliases;
    initExtra = ''
      shopt -s autocd
      export PATH="$HOME/bin:$PATH"
      export GIT_EDITOR="hx"

      function set-tab {
        wezterm cli set-tab-title "$1"
      }
    '';
  };

  programs.atuin.enable = true;

  programs.zoxide = {
    enableBashIntegration = true;
  };

  programs.atuin = {
    enableBashIntegration = true;
  };

  programs.starship = {
    enableBashIntegration = true;
  };
}
