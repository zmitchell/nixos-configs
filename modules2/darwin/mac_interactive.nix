{ config, inputs, ... }:
let
  hm_modules = with config.flake.modules.homeManager; [
    base
    ghostty
    git
    helix
    shell
    ssh_hosts
    styles
  ];
  generic_modules = with config.flake.modules.generic; [
    community_cachix
    host
    nixpkgs_unstable
    system_fonts
    user_profile_home
  ];
  darwin_modules = with config.flake.modules.darwin; [
    base
    dock
    finder
    keyboard
    ssh
    styles
    touchpad
  ];
  external_modules = [
    inputs.flox.darwinModules.flox
    inputs.home-manager.darwinModules.home-manager
    inputs.mac-app-util.darwinModules.default
    inputs.stylix.darwinModules.stylix
  ];
in
{
  flake.modules.darwin.mac_interactive = {
    imports =
      generic_modules
      ++ darwin_modules
      ++ external_modules
      ++ [
        (
          { config, pkgs, ... }:
          {
            programs.flox.enable = true;

            ssh = {
              tailscale.enable = true;
              remote_login.enable = false;
            };

            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = ".before-home-manager";
            home-manager.sharedModules = [
              inputs.mac-app-util.homeManagerModules.default
            ];
            home-manager.users.${config.user_profile.username} = {
              imports = hm_modules;

              home.packages = with pkgs; [
                podman
                unstable.lima
                utm
              ];

              git.jj.enable = true;
              shell = {
                atuin.enable = true;
                bash.enable = true;
                delta.enable = true;
                fish.enable = true;
                starship.enable = true;
                zoxide.enable = true;
              };
            };
          }
        )
      ];
  };
}
