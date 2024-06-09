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

  config = {
    generic_desktop.enable = lib.mkIf cfg.enable true;

    services.xserver.enable = lib.mkIf cfg.enable true;
    services.xserver.displayManager.gdm.enable = lib.mkIf cfg.enable true;
    services.xserver.desktopManager.gnome.enable = lib.mkIf cfg.enable true;
    services.xserver.displayManager.gdm.wayland = lib.mkIf cfg.enable true;
    environment.sessionVariables.NIXOS_OZONE_WL = lib.mkIf cfg.enable "1";

    # Basic applications
    programs.gnome-disks.enable = lib.mkIf cfg.enable true;
    programs.gnome-terminal.enable = lib.mkIf cfg.enable true;

    # Gnome packages
    environment.systemPackages = lib.mkIf cfg.enable defaultPackages;
  };
}
