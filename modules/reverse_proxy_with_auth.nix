{config, lib, user, ...}:
with lib; let
  cfg = config.reverse_proxy_with_auth;
  domain = "zmitchell.dev";
  ldapDn = "dc=zmitchell,dc=dev";
  ldapPort = 3890;
  ldapUIPort = ldapPort + 1;
  authDomain = "https://auth.${domain}";
  authPort = 9091;
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
  mkServiceConfig = service: ''
      ${if !service.public then ''
      forward_auth 127.0.0.1:${builtins.toString authPort} {
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
        "${service.subdomain}.${domain}"
        {
          extraConfig = mkServiceConfig service;
        })
    proxyServices;
in
{
  options.reverse_proxy_with_auth = {
    enable = mkEnableOption "Enable a reverse proxy with authentication.";
    services = with types; mkOption {
      type = attrsOf (submodule service);
      description = "The services to proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Proxy server
    services.caddy = {
      enable = true;
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      virtualHosts =
        (mkVirtualHosts cfg.services)
        // {
          "ldap.${domain}".extraConfig = ''
            forward_auth 127.0.0.1:${builtins.toString authPort} {
              uri /api/authz/forward-auth
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
            }
            reverse_proxy 127.0.0.1:${builtins.toString ldapUIPort}
            log
          '';
          "auth.${domain}".extraConfig = ''
            reverse_proxy 127.0.0.1:${builtins.toString authPort}
            log
          '';
        };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # Auth server
    services.authelia.instances.main = {
      enable = true;
      secrets.manual = true;
      environmentVariables = {
        AUTHELIA_JWT_SECRET_FILE = "/var/lib/authelia/jwt-secret";
        AUTHELIA_SESSION_SECRET_FILE = "/var/lib/authelia/session-secret";
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = "/var/lib/authelia/storage-secret";
      };
      settings = {
        theme = "auto";
        session.cookies = [
          {
            domain = domain;
            authelia_url = authDomain;
          }
        ];
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        authentication_backend.file.path = "/var/lib/authelia-main/users.yml";
        access_control = {
          default_policy = "deny";
          rules = [
            { domain = authDomain; policy = "bypass"; }
            { domain = "*.${domain}"; policy = "one_factor"; }
          ];
        };
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
      };
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/authelia 0750 authelia-main authelia-main - -"
    ];

    # LDAP server
    services.lldap = {
      enable = true;
      settings = {
        ldap_host = "127.0.0.0";
        ldap_port = ldapPort;
        http_url = "https://ldap.${domain}";
        http_port = ldapUIPort;
        ldap_base_dn = ldapDn;
        ldap_user_dn = user.username;
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = "/var/lib/lldap/jwt-secret";
        LLDAP_LDAP_USER_PASS_FILE = "/var/lib/lldap/initial-password";
      };
      silenceForceUserPassResetWarning = true;
    };
  };
}
