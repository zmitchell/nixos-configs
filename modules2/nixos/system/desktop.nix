{config, pkgs, lib, ...}:
let
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = lib.mkEnableOption "Configures a generic desktop without graphics";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        firefox
        tailscale
        helix
        yazi
        bat
        fd
        jq
        home-manager
        lsof
      ];
      description = "Basic system-wide packages";
    };
    base_fonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        input-fonts
        ubuntu-classic
        nerd-fonts.hack
        nerd-fonts.fira-code
        nerd-fonts.inconsolata
        nerd-fonts.symbols-only
      ];
      description = "Basic system-wide fonts to include";
    };
    allow_sleep = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow the system to enter sleep";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.packages;
    services.fwupd.enable = true;
    nixpkgs.config.input-fonts.acceptLicense = true;
    fonts.packages = cfg.base_fonts;
    systemd.targets.sleep.enable = cfg.allowSleep;
    systemd.targets.suspend.enable = cfg.allowSleep;
    systemd.targets.hibernate.enable = cfg.allowSleep;
    systemd.targets.hybrid-sleep.enable = cfg.allowSleep;
    services.displayManager.gdm.autoSuspend = cfg.allowSleep;
  };
}
