{
  config,
  lib,
  host,
  ...
}:
let
  ip_cfg = builtins.getAttr host (import ../data/static_ips.nix);
  cfg = config.static_ip;
in
{
  options.static_ip = {
    enable = lib.mkEnableOption "Set a static IP address for this host";
    default_gateway = lib.mkOption {
      type = lib.types.str;
      description = "The default gateway for the network.";
      example = "192.168.8.1";
      default = "192.168.8.1";
    };
    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The nameservers to use for DNS requests";
      example = [ "1.1.1.1" "4.4.4.4" ];
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.interfaces.${ip_cfg.interface} = {
      ipv4.addresses = [
        {
          address = ip_cfg.address;
          prefixLength = 24;
        }
      ];
      useDHCP = false;
    };
    networking.defaultGateway = cfg.default_gateway;
    networking.nameservers = cfg.nameservers;
  };
}
