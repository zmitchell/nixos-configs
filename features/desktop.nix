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
    gnome.evince # document viewer
    gnome.gedit # text editor
    gnome.eog # image viewer
    gnome.sushi # quick preview for nautilus
    gnome-console
  ];

  # Gnome settings
  environment.systemPackages = with pkgs; [
    gnome.dconf-editor
    dconf2nix
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
}
