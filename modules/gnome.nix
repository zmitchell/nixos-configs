{pkgs, config, lib, ...}:
let
  cfg = config.gnome;
  defaultPackages = with pkgs; [
      gnome.dconf-editor
      dconf2nix
      gnomeExtensions.dash-to-dock
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
      gnomeExtensions.logo-menu
      gnome.gnome-tweaks
      gnome-usage
      gnome.evince
      gnome.gedit
      gnome.eog
      gnome.sushi
      gnome-console
    ];
in
{
  options = {
    gnome.enable = lib.mkEnableOption "Configures a Gnome desktop";
  };

  config = lib.mkIf cfg.enable {
    generic_desktop.enable = true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.wayland = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Basic applications
    programs.gnome-disks.enable = true;
    programs.gnome-terminal.enable = true;

    # Gnome packages
    environment.systemPackages = defaultPackages;
    home-manager.users.zmitchell.home.stateVersion = "23.11";
  };
}
