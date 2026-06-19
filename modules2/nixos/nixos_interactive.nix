{
  config,
  inputs,
  modulesPath,
  ...
}:
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
    ssh
  ];
  nixos_modules = with config.flake.modules.nixos; [
    base
    systemd_boot
    audio
    disallow_sleep
    kde
    fwupd
  ];
  external_modules = [
    inputs.flox.nixosModules.flox
    inputs.home-manager.nixosModules.home-manager
    inputs.flake-programs-sqlite.nixosModules.default
    inputs.stylix.nixosModules.stylix
  ];
in
{
  flake.modules.nixos.nixos_interactive = {
    imports =
      (modulesPath + "/installer/scan/not-detected.nix") generic_modules
      ++ nixos_modules
      ++ external_modules
      ++ [
        (
          { config, pkgs, ... }:
          {
            programs.flox.enable = true;

            ssh = {
              tailscale.enable = true;
              remote_login.enable = true;
            };

            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "before-home-manager";
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
                broot.enable = true;
              };
            };
          }
        )
      ];
  };
}
