{pkgs, config, lib, user, ...}:
let
  cfg = config.generic_desktop;
in
{
  imports = [
    ./audio.nix
    ./shell.nix
  ];
  options.generic_desktop = {
    enable = lib.mkEnableOption "Configures a generic desktop without graphics";
    systemPackages = lib.mkOption {
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
    allowSleep = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow the system to enter sleep";
    };
  };

  config = lib.mkIf cfg.enable {
    desktop_audio.enable = true;
    shell_config.enable = true;
    modern_boot.enable = true;

    environment.systemPackages = cfg.systemPackages;

    nixpkgs.config.input-fonts.acceptLicense = true;
    fonts.packages = cfg.base_fonts;

    systemd.targets.sleep.enable = cfg.allowSleep;
    systemd.targets.suspend.enable = cfg.allowSleep;
    systemd.targets.hibernate.enable = cfg.allowSleep;
    systemd.targets.hybrid-sleep.enable = cfg.allowSleep;
    services.displayManager.gdm.autoSuspend = cfg.allowSleep;
    home-manager.users.${user.username}.dconf.settings = {
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-ac-timeout = 0;
      };
    };
  };
}
