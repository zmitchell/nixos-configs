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
      public = mkOption {
        type = bool;
        description = "Whether to expose this subdomain without authentication";
        default = false;
      };
    };
  };
  mkExtraConfig = service: ''
      ${if !service.public then ''
      forward_auth 127.0.0.1:9091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      '' else null}
      reverse_proxy localhost:${builtins.toString service.port}
      log
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
      virtualHosts = mkVirtualHosts cfg.services // {
        "auth.${cfg.domain}".extraConfig = ''
          reverse_proxy 127.0.0.1:9091
        '';
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
