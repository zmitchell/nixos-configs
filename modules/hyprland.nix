{pkgs, inputs, lib, config, ...}:
let
  cfg = config.hyprland;
  defaultPackages = with pkgs; [
    wofi
    yazi
    gnome.nautilus
  ];
in
{
  options = {
    hyprland.enable = lib.mkEnableOption "Configure a Hyprland desktop";
  };

  config = lib.mkIf cfg.enable {
    generic_desktop.enable = true;

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # Internet is nice
    networking.networkmanager.enable = true;

    # More fixes to try to unfuck the missing cursor
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      MOX_ENABLE_WAYLAND = "1";
    };

    # Unfuck the missing cursor until I figure out a real solution
    home-manager.users.zmitchell.home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 28;
    };

    # Enable a statusbar at the top
    programs.waybar.enable = true;

    home-manager.users.zmitchell.home.stateVersion = "23.11";
    home-manager.users.zmitchell.home.packages = defaultPackages;
  };
}
