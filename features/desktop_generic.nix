{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    kitty
    firefox
    nvtop
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
