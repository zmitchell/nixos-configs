{
  config,
  inputs,
  ...
}:
{
  flake.darwinConfigurations.chonker = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      # Contains the base configuration with good defaults
      config.flake.modules.darwin.mac_interactive
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

          home-manager.users.${config.user_profile.username} = {
            home.stateVersion = "24.05";

            ghostty = {
              font_size = 13;
              keybinds = [
                "alt+h=goto_split:left"
                "alt+j=goto_split:down"
                "alt+k=goto_split:up"
                "alt+l=goto_split:right"
              ];
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
