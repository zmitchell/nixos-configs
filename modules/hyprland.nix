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

  config = {
    generic_desktop.enable = true;

    programs.hyprland = lib.mkIf cfg.enable {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # Internet is nice
    networking.networkmanager.enable = lib.mkIf cfg.enable true;

    # More fixes to try to unfuck the missing cursor
    environment.sessionVariables = lib.mkIf cfg.enable {
      WLR_NO_HARDWARE_CURSORS = "1";
      MOX_ENABLE_WAYLAND = "1";
    };

    # Unfuck the missing cursor until I figure out a real solution
    home-manager.users.zmitchell.home.pointerCursor = lib.mkIf cfg.enable {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 28;
    };

    # Enable a statusbar at the top
    programs.waybar.enable = lib.mkIf cfg.enable true;

    home-manager.users.zmitchell.home.stateVersion = "23.11";
    home-manager.users.zmitchell.home.packages = lib.mkIf cfg.enable defaultPackages;
  };
}
