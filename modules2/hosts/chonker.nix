{
  config,
  inputs,
  ...
}:
let
  homeManagerModules = with config.flake.modules.homeManager; [
    base
    ghostty
    git
    helix
    shell
    ssh_hosts
    styles
  ];
in
{
  flake.darwinConfigurations.chonker = inputs.nix-darwin.lib.darwinSystem {
    modules =
      (with config.flake.modules.generic; [
        community_cachix
        host
        nixpkgs_unstable
        system_fonts
        user_profile_home
      ])
      ++ (with config.flake.modules.darwin; [
        base
        dock
        finder
        keyboard
        ssh
        styles
        touchpad
      ])
      ++ [
        inputs.flox.darwinModules.flox
        inputs.home-manager.darwinModules.home-manager
        inputs.mac-app-util.darwinModules.default
        inputs.stylix.darwinModules.stylix
      ]
      ++ [
        (
          { config, pkgs, ... }:
          {
            # Never change these
            host = "chonker";
            system.stateVersion = 4;
            nixpkgs.hostPlatform = "aarch64-darwin";
            # Nix changed its nixbld user ids from 30000
            # to 350 at some point, so we need this override
            # unless we completely uninstall and reinstall
            # Nix.
            ids.gids.nixbld = 350;

            programs.flox.enable = true;

            ssh = {
              tailscale.enable = true;
              remote_login.enable = false;
            };
            dock.apps = {
              system = [
                "Finder"
                "Messages"
                "Calendar"
              ];
              user = [
                "Firefox"
                "Signal"
                "Obsidian"
                "Spark Desktop"
                "Ghostty"
                "1Password"
              ];
            };

            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = ".before-home-manager";
            home-manager.sharedModules = [
              inputs.mac-app-util.homeManagerModules.default
            ];
            home-manager.users.${config.user_profile.username} = {
              imports = homeManagerModules;

              home.stateVersion = "24.05";
              home.packages = with pkgs; [
                podman
                unstable.lima
                utm
              ];

              ghostty = {
                font_size = 13;
                keybinds = [
                  "alt+h=goto_split:left"
                  "alt+j=goto_split:down"
                  "alt+k=goto_split:up"
                  "alt+l=goto_split:right"
                ];
              };
              git.jj.enable = true;
              shell = {
                atuin.enable = true;
                bash.enable = true;
                delta.enable = true;
                fish.enable = true;
                starship.enable = true;
                zoxide.enable = true;
              };
              ssh_hosts.hosts = {
                chungus = {
                  host = "chungus";
                  hostname = "192.168.8.186";
                };
                chungus-ts = {
                  host = "chungus-ts";
                  hostname = "chungus";
                };
                smolboi = {
                  host = "smolboi";
                  hostname = "192.168.8.166";
                };
              };
            };
          }
        )
      ];
  };
}
