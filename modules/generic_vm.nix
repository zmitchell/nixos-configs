
{pkgs, config, lib, ...}:
let
  cfg = config.generic_vm;
in
{
  imports = [
    ./audio.nix
    ./shell.nix
    ./git.nix
  ];
  options.generic_vm = {
    enable = lib.mkEnableOption "Configures a generic desktop without graphics";
    systemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
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
    allowSleep = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow the system to enter sleep";
    };
  };

  config = lib.mkIf cfg.enable {
    git_config.enable = true;
    shell_config.enable = true;

    environment.systemPackages = cfg.systemPackages;

    nixpkgs.config.input-fonts.acceptLicense = true;

    systemd.targets.sleep.enable = cfg.allowSleep;
    systemd.targets.suspend.enable = cfg.allowSleep;
    systemd.targets.hibernate.enable = cfg.allowSleep;
    systemd.targets.hybrid-sleep.enable = cfg.allowSleep;
    services.xserver.displayManager.gdm.autoSuspend = cfg.allowSleep;
  };
}
