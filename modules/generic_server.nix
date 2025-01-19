{pkgs, config, lib, ...}:
let
  cfg = config.generic_server;
in
{
  imports = [
    ./shell.nix
  ];
  options.generic_server = {
    enable = lib.mkEnableOption "Configures a generic remote server";
    systemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
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
  };

  config = lib.mkIf cfg.enable {
    shell_config.enable = true;
    environment.systemPackages = cfg.systemPackages;
  };
}
