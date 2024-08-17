
{pkgs, config, lib, ...}:
let
  cfg = config.kde;
in
{
  options = {
    kde.enable = lib.mkEnableOption "Configures a KDE Plasma desktop";
  };

  config = lib.mkIf cfg.enable {
    generic_desktop.enable = true;

    services.xserver.enable = true;
    services.displayManager.defaultSession = "plasma";
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    home-manager.users.zmitchell.home.stateVersion = "23.11";
  };
}
