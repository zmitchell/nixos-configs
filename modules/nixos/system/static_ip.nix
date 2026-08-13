{
  flake.modules.nixos.static_ip =
    { config, lib, ... }:
    let
      cfg = config.static_ip;
    in
    {
      options.static_ip = {
        ip = lib.mkOption {
          type = lib.types.str;
          description = "The static IP to bind to.";
          example = "192.168.8.123";
        };
        gateway = lib.mkOption {
          type = lib.types.str;
          description = "The router's default gateway.";
          example = "192.168.8.1";
        };
        interface = lib.mkOption {
          type = lib.types.str;
          description = "The interface to bind the static IP address to.";
          example = "wlp8s0";
        };
        nameservers = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          description = "Use explicit nameservers instead of those from the router.";
          example = [
            "1.1.1.1"
            "4.4.4.4"
          ];
          default = null;
        };
      };

      config = {
        networking.defaultGateway = cfg.gateway;
        networking.nameservers = lib.mkIf (cfg.nameservers != null) cfg.nameservers;
        networking.interfaces.${cfg.interface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = cfg.ip;
              prefixLength = 24;
            }
          ];
        };
      };
    };
}
