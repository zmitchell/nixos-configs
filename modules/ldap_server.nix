{ config, lib, user, pkgs, ...}:
let
  cfg = config.ldap_server;
in
{
  options.ldap_server = {
    enable = lib.mkEnableOption "A lightweight LDAP server based on lldap";
  };

  config = lib.mkIf cfg.enable {
    services.lldap = {
      enable = true;
      settings = {
        ldap_host = "127.0.0.0";
        ldap_port = 3890;
        http_url = "https://ldap.zmitchell.dev";
        http_port = 3891;
        ldap_base_dn = "dc=zmitchell,dc=dev";
        ldap_user_dn = user.username;
      };
      environment = {
        LLDAP_JWT_SECRET_FILE = "/var/lib/lldap/jwt-secret";
        LLDAP_LDAP_USER_PASS_FILE = "/var/lib/lldap/initial-password";
      };
      silenceForceUserPassResetWarning = true;
    };
    reverse_proxy.services.ldap = {
      subdomain = "ldap";
      port = 3891;
    };
  };
}
