{
  flake.modules.nixos.gnome =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.gnome;
    in
    {
      options.gnome = {
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          description = "The Gnome packages to install.";
          default = with pkgs; [
            dconf-editor
            dconf2nix
            gnomeExtensions.dash-to-dock
            gnomeExtensions.just-perfection
            gnomeExtensions.appindicator
            gnomeExtensions.logo-menu
            gnome-tweaks
            gnome-usage
            pkgs.evince
            pkgs.gedit
            pkgs.eog
            pkgs.sushi
            gnome-console
          ];
        };
        allow_sleep = lib.mkOption {
          type = lib.types.bool;
          description = "Whether to allow Gnome to send the machine to sleep.";
          default = true;
        };
      };

      config = {
        services.xserver.enable = true;
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;
        services.displayManager.gdm.wayland = true;
        services.displayManager.gdm.autoSuspend = cfg.allow_sleep;
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        # Basic applications
        programs.gnome-disks.enable = true;
        programs.gnome-terminal.enable = true;

        # Gnome packages
        environment.systemPackages = cfg.packages;
      };
    };
}
