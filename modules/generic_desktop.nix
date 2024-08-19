{pkgs, config, lib, ...}:
let
  cfg = config.generic_desktop;
in
{
  imports = [
    ./audio.nix
    ./shell.nix
    ./git.nix
  ];
  options.generic_desktop = {
    enable = lib.mkEnableOption "Configures a generic desktop without graphics";
    systemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        kitty
        firefox
        tailscale
        neovim
        helix
        yazi
        ripgrep
        bat
        fd
        jq
        neofetch
        home-manager
        lsof
        ranger
      ];
      description = "Basic system-wide packages";
    };
    base_fonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
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
    git_config.enable = true;
    shell_config.enable = true;

    environment.systemPackages = cfg.systemPackages;

    nixpkgs.config.input-fonts.acceptLicense = true;
    fonts.packages = cfg.base_fonts;

    systemd.targets.sleep.enable = cfg.allowSleep;
    systemd.targets.suspend.enable = cfg.allowSleep;
    systemd.targets.hibernate.enable = cfg.allowSleep;
    systemd.targets.hybrid-sleep.enable = cfg.allowSleep;
    services.xserver.displayManager.gdm.autoSuspend = cfg.allowSleep;
  };
}
