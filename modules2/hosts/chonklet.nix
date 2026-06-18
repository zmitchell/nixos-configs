{
  config,
  inputs,
  ...
}:
{
  flake.darwinConfigurations.chonklet = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      # Contains the base configuration with good defaults
      config.flake.modules.darwin.mac_interactive
      config.flake.modules.generic.user_profile_home
      (
        { config, pkgs, ... }:
        {
          # Never change these
          host = "chonklet";
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";

          # System-level module customizations
          dock.apps = {
            system = [
              "Finder"
              "Calendar"
            ];
            user = [
              "Firefox"
              "Obsidian"
              "Ghostty"
              "1Password"
              "Slack"
            ];
          };

          home-manager.users.${config.user_profile.username} = {
            # Never change this
            home.stateVersion = "24.05";

            # User-level module customizations
            ghostty = {
              font_size = 13;
              keybinds = [
                "ctrl+tab=unbind"
              ];
            };
            home.packages = with pkgs; [
              docker-client
              docker-compose
            ];
          };
        }
      )
    ];
  };
}
