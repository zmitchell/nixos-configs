# Documentation
#
# ## Authentication
#
# We use Authelia as the authentication server because it's lightweight and
# simple to configure. LDAP is used as the authentication backend so that
# there's only one list of users, passwords, etc rather than one per service.
#
# Each service definition defines the subdomain it should be placed under, then
# that subdomain is restricted via Authelia rules and LDAP ACLs.
#
# ## LDAP
#
# We use LLDAP as the LDAP server again because it's lightweight and simple to
# configure. It's exposed under the `ldap.*` subdomain. A `ldap_admin` user is
# configured to have access to this portal so that you can use the web UI to
# administer users. This means that you'll need to create the `ldap_admin` user
# on first launch to make sure that they exist in the LLDAP database.
#
# Generic users are placed in the `people` group, which is the default group
# that is allowed to authenticate against private services. You can create
# groups in LLDAP that are subsets of `people`, then use the `aclSubjects`
# option on the service submodule to restrict a service to certain groups of
# users.
{config, lib, user, ...}:
with lib; let
  cfg = config.reverse_proxy_with_auth;
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
      aclSubjects = mkOption {
        type = nullOr (listOf str);
        default = [ "group:people" ];
        description = "The list of ACL subjects that may access this subdomain. See the Authelia documentation for details.";
        example = [ "group:people" "user:bob" ];
      };
    };
  };
in
{
  options.reverse_proxy_with_auth = {
    enable = mkEnableOption "Enable a reverse proxy with authentication.";
    domain = with types; mkOption {
      type = str;
      description = "The root domain to proxy behind.";
      example = "example.com";
    };
    authSubdomain = with types; mkOption {
      type = str;
      default = "auth";
      description = "The subdomain to serve Authelia from.";
    };
    ldapSubdomain = with types; mkOption {
      type = str;
      default = "ldap";
      description = "The subdomain to serve LLDAP from.";
    };
    authPort = with types; mkOption {
      type = port;
      description = "The port to host the Authelia server on.";
      default = 9091;
    };
    ldapPort = with types; mkOption {
      type = port;
      description = "The port to host the LLDAP server on.";
      default = 3890;
    };
    ldapUIPort = with types; mkOption {
      type = port;
      description = "The port to host the LLDAP admin UI on.";
      default = 3891;
    };
    services = with types; mkOption {
      type = attrsOf (submodule service);
      description = "The services to proxy.";
    };
    aclSubjectsDefault = mkOption {
      type = listOf str;
      default = [ "group:people" ];
      description = "The list of ACL subjects that may access this subdomain. See the Authelia documentation for details.";
      internal = true;
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable (
  let
    authDomain = "${cfg.authSubdomain}.${cfg.domain}";
    ldapDomain = "${cfg.ldapSubdomain}.${cfg.domain}";
    ldapDn = builtins.concatStringsSep "," (builtins.map (part: "dc=${part}") (lib.strings.splitString "." cfg.domain));
    mkServiceConfig = service: ''
        ${if !service.public then ''
        forward_auth 127.0.0.1:${builtins.toString cfg.authPort} {
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
            extraConfig = mkServiceConfig service;
          })
      proxyServices;
    mkServiceACL = service: {
      domain = "${service.subdomain}.${cfg.domain}";
      policy = if service.public then "bypass" else "one_factor";
      subject = if (service.aclSubjects == null) then cfg.aclSubjectsDefault else service.aclSubjects;
    };

  in
  {
    # Proxy server
    services.caddy = {
      enable = true;
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      virtualHosts =
        (mkVirtualHosts cfg.services)
        // {
          "${ldapDomain}".extraConfig = ''
            forward_auth 127.0.0.1:${builtins.toString cfg.authPort} {
              uri /api/authz/forward-auth
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
            }
            reverse_proxy 127.0.0.1:${builtins.toString cfg.ldapUIPort}
            log
          '';
          "${authDomain}".extraConfig = ''
            reverse_proxy 127.0.0.1:${builtins.toString cfg.authPort}
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
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "/var/lib/authelia/ldap-secret";
      };
      settings = {
        theme = "auto";
        session.cookies = [
          {
            domain = cfg.domain;
            authelia_url = "https://${authDomain}";
          }
        ];
        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = authDomain;
              policy = "bypass";
            }
            {
              domain = ldapDomain;
              policy = "one_factor";
              subject = [ "group:lldap_admin" ];
            }
          ] ++ builtins.map mkServiceACL (builtins.attrValues cfg.services);
        };
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
        authentication_backend.ldap = {
          implementation = "custom";
          address = "ldap://127.0.0.1:${builtins.toString cfg.ldapPort}";
          timeout = "5s";
          start_tls = false;

          base_dn = ldapDn;
          user = "uid=authelia,ou=people,${ldapDn}";

          additional_users_dn = "ou=people";
          additional_groups_dn = "ou=groups";

          users_filter = "(&(|({username_attribute}={input})(mail={input}))(objectClass=person))";
          groups_filter = "(&(objectClass=groupOfNames)(member={dn}))";

          attributes = {
            username = "uid";
            display_name = "cn";
            mail = "mail";
            group_name = "cn";
          };
        };
      };
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/authelia 0750 authelia-main authelia-main - -"
    ];
    systemd.services.authelia-main.after = [ "lldap.service" ];
    systemd.services.authelia-main.requires = [ "lldap.service" ];
    

    # LDAP server
    services.lldap = {
      enable = true;
      settings = {
        ldap_host = "127.0.0.1";
        ldap_port = cfg.ldapPort;
        http_url = "https://${ldapDomain}";
        http_port = cfg.ldapUIPort;
        ldap_base_dn = ldapDn;
        ldap_user_dn = user.username;
        verbose = true;
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = "/var/lib/lldap/jwt-secret";
        LLDAP_LDAP_USER_PASS_FILE = "/var/lib/lldap/initial-password";
      };
      silenceForceUserPassResetWarning = true;
    };
  });
}
