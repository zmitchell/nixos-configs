{ config, lib, pkgs, ...}:
  let cfg = config.mealie;
in
{
  options.mealie = {
    enable = lib.mkEnableOption "Enable the mealie server.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = lib.mdDoc "Port for the mealie server.";
    };
    useReverseProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to put these services behind the reverse proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mealie = {
      enable = true;
      port = cfg.port;
      listenAddress = "127.0.0.1";
      package = pkgs.unstable.mealie;
    };
    reverse_proxy_with_auth.services.recipes = lib.mkIf cfg.useReverseProxy {
      subdomain = "recipes";
      port = cfg.port;
    };
  };
}
