{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.reverse_proxy;
  service = {
    options = with types; {
      subdomain = mkOption {
        type = str;
        description = "The subdomain to put the service under.";
      };
      port = mkOption {
        type = port;
        description = "The port that the service is running on locally";
      };
    };
  };
  mkExtraConfig = service: ''
      reverse_proxy localhost:${builtins.toString service.port}
      log
      basic_auth {
        # FIXME: this is temporary
        admin $2a$14$HAkQyHHIOZHSK5YurCfY8.iKuhOZB5AJTemex0dKQ2mlk2pD.K5uy
      }
  '';
  mkVirtualHosts = with lib.attrsets; proxyServices: mapAttrs'
    (name: service:
      nameValuePair
        "${service.subdomain}.${cfg.domain}"
        {
          extraConfig = mkExtraConfig service;
        })
    proxyServices;
in
{
  options.reverse_proxy = {
    enable = mkEnableOption "Enable a reverse proxy for local services.";
    domain = with types; mkOption {
      type = str;
      description = "The root domain to place the services under.";
    };
    services = with types; mkOption {
      type = attrsOf (submodule service);
      description = "The services to proxy.";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      virtualHosts = mkVirtualHosts cfg.services;
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
