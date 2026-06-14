{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.desktop_environments.kde;
in
{
  options.desktop_environments = {
    kde.enable = lib.mkEnableOption "Configures a KDE Plasma desktop";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.defaultSession = "plasma";
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
