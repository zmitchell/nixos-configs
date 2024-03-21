{pkgs, ...}:
{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Basic applications
  programs.gnome-disks.enable = true;
  programs.gnome-terminal.enable = true;
  users.users.zmitchell.packages = with pkgs; [
    firefox
  ];

  # Gnome packages
  environment.systemPackages = with pkgs; [
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

  # Fonts
  nixpkgs.config.input-fonts.acceptLicense = true;
  fonts.packages = with pkgs; [
    input-fonts
    ubuntu_font_family
    (nerdfonts.override {
      fonts = [
        "Hack"
        "FiraCode"
        "Inconsolata"
        "NerdFontsSymbolsOnly"
      ];
    })
  ];

  # Don't let the system sleep, it's a server
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  services.xserver.displayManager.gdm.autoSuspend = false;
}
