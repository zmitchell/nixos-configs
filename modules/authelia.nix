{ config, lib, pkgs, ...}:
let
  cfg = config.authelia;
  domain = config.reverse_proxy.domain;
  authDomain = "https://auth.${config.reverse_proxy.domain}";
  mkPublicSubdomain = name: { domain = "${name}.${domain}"; policy = "bypass";};
in
{
  options.authelia = {
    enable = lib.mkEnableOption "Enable the authelia server.";
    publicSubdomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
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
          ] ++ builtins.map mkPublicSubdomain cfg.publicSubdomains;
        };
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
      };
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/authelia 0750 authelia-main authelia-main - -"
    ];
  };
}

