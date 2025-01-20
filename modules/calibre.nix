{ config, lib, ...}:
  let cfg = config.calibre;
in
{
  options.calibre = {
    enable = lib.mkEnableOption "Enable the calibre-server and calibre-web services.";
    calibreServerPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = lib.mdDoc "Port for the calibre-server server.";
    };
    calibreWebPort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = lib.mdDoc "Port for the calibre-web server.";
    };
    useReverseProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to put these services behind the reverse proxy.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "calibre";
      description = "Which user will run the calibre services";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "calibre";
      description = "Which group the calibre services run under.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.calibre-server = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      port = cfg.calibreServerPort;
      host = "127.0.0.1";
      openFirewall = true;
    };

    services.calibre-web = {
      enable = true;
      user = builtins.toString cfg.user;
      group = cfg.group;
      openFirewall = true;
      listen = {
        port = cfg.calibreWebPort;
        ip = "127.0.0.1";
      };
      options = {
        enableBookUploading = true;
        calibreLibrary = builtins.elemAt config.services.calibre-server.libraries 0;
      };
    };

    users.users = {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = {
      ${cfg.group} = {};
    };

    # Configure the user and group for the services
    # users.users.${cfg.user} = {
    #   name = cfg.user;
    #   group = cfg.group;
    #   isSystemUser = true;
    #   description = "The user that runs the calibre services";
    # };
    # users.groups.${cfg.group}.name = cfg.group;
  };
}
