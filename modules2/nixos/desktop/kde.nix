{
  flake.modules.nixos.kde = {
    services.xserver.enable = true;
    services.displayManager.defaultSession = "plasma";
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
