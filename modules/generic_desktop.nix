{pkgs, config, lib, ...}:
let
  cfg = config.desktop_generic;
in
{
  imports = [
    ./audio.nix
    ./shell.nix
    ./git.nix
  ];
  options.generic_desktop = {
    enable = lib.mkEnableOption "Enable generic desktop settings";
    systemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        kitty
        firefox
        nvtop
        tailscale
        neovim
        helix
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

  config = {
    audio.enable = true;
    git_config.enable = true;
    shell_config.enable = true;

    environment.systemPackages = lib.mkIf cfg.enable cfg.systemPackages;

    nixpkgs.config.input-fonts.acceptLicense = lib.mkIf cfg.enable true;
    fonts.packages = lib.mkIf cfg.enable cfg.base_fonts;

    systemd.targets.sleep.enable = lib.mkIf cfg.enable cfg.allowSleep;
    systemd.targets.suspend.enable = lib.mkIf cfg.enable cfg.allowSleep;
    systemd.targets.hibernate.enable = lib.mkIf cfg.enable cfg.allowSleep;
    systemd.targets.hybrid-sleep.enable = lib.mkIf cfg.enable cfg.allowSleep;
    services.xserver.displayManager.gdm.autoSuspend = lib.mkIf cfg.enable cfg.allowSleep;
  };
}
