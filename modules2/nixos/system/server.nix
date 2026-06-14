{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.server;
in
{
  options.server = {
    enable = lib.mkEnableOption "Configures a generic remote server";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        tailscale
        helix
        yazi
        bat
        fd
        jq
        lsof
      ];
      description = "Basic system-wide packages";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.packages;
  };
}
