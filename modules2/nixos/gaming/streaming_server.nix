{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.gaming.streaming_server;
in
{
  options.gaming.streaming_server = {
    enable = lib.mkEnableOption "Enable a game streaming server";
  };

  config = lib.mkIf cfg.enable {
    # Sunshine game streaming server
    services.sunshine = {
      enable = true;
      openFirewall = true;
      capSysAdmin = true;
      # Enable nvenc support
      package = pkgs.withCudaSupport.sunshine;
    };
  };
}
