{ config, lib, pkgs, ...}:
with lib; let
  cfg = config.booklore;
in
{
  options.booklore = {
    enable = mkEnableOption "Run the Booklore server.";
    useReverseProxy = with types; mkOption {
      type = bool;
      default = false;
      description = "Whether to serve Booklore behind an authenticated proxy.";
    };
    aclSubjects = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "ACL subjects";
    };
    user = with types; mkOption {
      type = str;
      default = "booklore";
      description = "The user to run booklore as.";
    };
    userID = with types; mkOption {
      type = int;
      default = 4100;
      description = "The user ID of the Booklore user.";
    };
    group = with types; mkOption {
      type = str;
      default = "booklore";
      description = "The group to run booklore as.";
    };
    groupID = with types; mkOption {
      type = int;
      default = 4100;
      description = "The group ID of the Booklore user.";
    };
    bookloreImage = with types; mkOption {
      type = str;
      default = "ghcr.io/booklore-app/booklore";
      description = "The image URL of the Booklore container to run.";
    };
    bookloreImageTag = with types; mkOption {
      type = str;
      default = "latest";
      description = "The tag for the Booklore container image";
    };
    mariadbImage = with types; mkOption {
      type = str;
      default = "lscr.io/linuxserver/mariadb";
      description = "The image URL of the MariaDB container to run.";
    };
    mariadbImageTag = with types; mkOption {
      type = str;
      default = "latest";
      description = "The tag for the MariadDB container image";
    };
    booklorePort = with types; mkOption {
      type = port;
      default = 6060;
      description = "The port to run Booklore on.";
    };
    mariadbPort = with types; mkOption {
      type = port;
      default = 3306;
      description = "The port to run Booklore's database on.";
    };
    timezone = with types; mkOption {
      type = str;
      default = "America/Denver";
      description = "The timezone for Booklore and its database";
    };
  };

  config = mkIf cfg.enable {
    # The system user to run as if we need to create it
    users.users = mkIf (cfg.user == "booklore") {
      booklore = {
        isSystemUser = true;
        uid = cfg.userID;
        group = cfg.group;
      };
    };
    users.groups = mkIf (cfg.group == "booklore") {
      booklore = {
        gid = cfg.groupID;
      };
    };

    # Container networking
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    systemd.services.podman-network-booklore = {
      description = "Ensure Podman network for Booklore exists";
      wantedBy = [ "multi-user.target" ];
      before = [
        "podman-booklore.service"
        "podman-booklore-mariadb.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.runtimeShell} -c \"${pkgs.podman}/bin/podman network exists booklore || ${pkgs.podman}/bin/podman network create --driver bridge --subnet 10.111.42.0/24 --gateway 10.111.42.1 booklore\"";
      };
    };
    systemd.services."podman-booklore".after =
      lib.mkAfter [ "podman-network-booklore.service" ];
    systemd.services."podman-booklore".requires =
      lib.mkAfter [ "podman-network-booklore.service" ];
    systemd.services."podman-booklore-mariadb".after =
      lib.mkAfter [ "podman-network-booklore.service" ];
    systemd.services."podman-booklore-mariadb".requires =
      lib.mkAfter [ "podman-network-booklore.service" ];

    # Booklore container
    virtualisation.oci-containers.containers.booklore = {
      image = "${cfg.bookloreImage}:${cfg.bookloreImageTag}";
      dependsOn = [ "booklore-mariadb" ];
      ports = [
        "${builtins.toString cfg.booklorePort}:${builtins.toString cfg.booklorePort}"
      ];
      autoStart = true;
      environment = {
        USER_ID = builtins.toString cfg.userID;
        GROUP_ID = builtins.toString cfg.groupID;
        DATABASE_URL = "jdbc:mariadb://booklore-mariadb:${builtins.toString cfg.mariadbPort}/booklore";
        DATABASE_USERNAME = "booklore";
        TZ = cfg.timezone;
      };
      environmentFiles = [
        # Needs:
        # - DATABASE_PASSWORD
        "/var/lib/booklore/envs"
      ];
      volumes = [
        "/var/lib/booklore/data:/app/data"
        "/var/lib/booklore/books:/books"
        "/var/lib/booklore/bookdrop:/bookdrop"
      ];
    };

    # Backing database container
    virtualisation.oci-containers.containers.booklore-mariadb = {
      image = "${cfg.mariadbImage}:${cfg.mariadbImageTag}";
      ports = [
        "${builtins.toString cfg.mariadbPort}:${builtins.toString cfg.mariadbPort}"
      ];
      autoStart = true;
      environment = {
        PUID = builtins.toString cfg.userID;
        PGUID = builtins.toString cfg.groupID;
        TZ = cfg.timezone;
        MYSQL_DATABASE = "booklore";
        MYSQL_USER = "booklore";
      };
      environmentFiles = [
        # Needs:
        # - MYSQL_PASSWORD
        # - MYSQL_ROOT_PASSWORD
        "/var/lib/booklore/envs"
      ];
      extraOptions = [
        "--health-cmd=mariadb-admin ping -h localhost"
        "--health-interval=5s"
        "--health-timeout=5s"
        "--health-retries=10"
      ];
      volumes = [
        "/var/lib/booklore/config:/config"
      ];
    };

    systemd.tmpfiles.settings."10-booklore" = {
      # Root directory
      "/var/lib/booklore".d = {
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      };

      # Application data, logs, etc
      "/var/lib/booklore/data".d = {
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      };

      # Main book/library storage
      "/var/lib/booklore/books".d = {
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      };

      # Automatic book import directory
      "/var/lib/booklore/bookdrop".d = {
        user = cfg.user;
        group = cfg.group;
        mode = "0744";
      };

      # Database config and data
      "/var/lib/booklore/config/mariadb".d = {
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      };
    };

    reverse_proxy_with_auth.services.booklore = mkIf cfg.useReverseProxy {
      subdomain = "booklore";
      aclSubjects = cfg.aclSubjects;
      port = cfg.booklorePort;
    };
  };
}
