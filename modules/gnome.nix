{pkgs, config, lib, ...}:
let
  cfg = config.gnome;
  defaultPackages = with pkgs; [
      pkgs.dconf-editor
      dconf2nix
      gnomeExtensions.dash-to-dock
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
      gnomeExtensions.logo-menu
      pkgs.gnome-tweaks
      gnome-usage
      pkgs.evince
      pkgs.gedit
      pkgs.eog
      pkgs.sushi
      gnome-console
    ];
in
{
  options = {
    gnome.enable = lib.mkEnableOption "Configures a Gnome desktop";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.wayland = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Basic applications
    programs.gnome-disks.enable = true;
    programs.gnome-terminal.enable = true;

    # Gnome packages
    environment.systemPackages = defaultPackages;
  };
}
