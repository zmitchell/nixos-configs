{config, lib, pkgs, user, ...}:
with lib; let
  cfg = config.monitoring;
  grafanaLdapConfig = (pkgs.formats.toml {}).generate "ldap.toml" {
    servers = [
      {
        host = "127.0.0.1";
        port = config.reverse_proxy_with_auth.ldapPort;
        use_ssl = false;
        start_tls = false;
        bind_dn = "uid=grafana_lookup,ou=people,dc=zmitchell,dc=dev";
        bind_password = "$__file{/var/lib/grafana/ldap-secret}";
        search_base_dns = ["ou=people,dc=zmitchell,dc=dev"];
        search_filter = "(uid=%s)";
      
        attributes = {
          username = "uid";
          member_of = "memberOf";
          email = "mail";
          name = "cn";
        };

        group_mappings = [
          {
            group_dn = "cn=grafana_admins,ou=groups,dc=zmitchell,dc=dev";
            org_role = "Admin";
          }
          {
            group_dn = "cn=friends,ou=groups,dc=zmitchell,dc=dev";
            org_role = "Viewer";
          }
        ];
      }
    ];
  };
in
{
  options.monitoring = {
    enable = mkEnableOption "Enable metrics, logs, and dashboards.";
    useReverseProxy = with types; mkOption {
      type = bool;
      default = false;
      description = "Whether to serve logs/metrics/dashboards behind an authenticated proxy.";
    };
    metrics = with types; {
      nodeExporterPort = mkOption {
        type = port;
        default = 9100;
      };
      port = mkOption {
        type = port;
        default = 8428;
      };
      subdomain = mkOption {
        type = str;
        default = "metrics";
        description = "The subdomain to host vmui under.";
      };
    };
    logs = with types; {
      port = mkOption {
        type = port;
        default = 9428;
      };
      subdomain = mkOption {
        type = str;
        default = "logs";
        description = "The subdomain to host VictoriaLogs under.";
      };
    };
    graphs = with types; {
      port = mkOption {
        type = port;
        default = 9429;
      };
      subdomain = mkOption {
        type = str;
        default = "grafana";
        description = "The subdomain to host Grafana under.";
      };
    };
  };

  config = mkIf cfg.enable {

    # VictoriaMetrics itself
    services.victoriametrics = {
      enable = true;
      extraOptions = [
        "-retentionPeriod=90d"
        "-selfScrapeInterval=10s"
      ];
      listenAddress = "127.0.0.1:${builtins.toString cfg.metrics.port}";
      prometheusConfig = {
        global.scrape_interval = "15s";
        scrape_configs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "127.0.0.1:${builtins.toString cfg.metrics.nodeExporterPort}"];
              }
            ];
          }
        ];
      };
    };
    reverse_proxy_with_auth.services.victoriametrics = {
      subdomain = cfg.metrics.subdomain;
      aclSubjects = ["user:${user.username}"];
      port = cfg.metrics.port;
      routeRedirects = [
        {
          from = "/";
          to = "/vmui";
        }
      ];
    };

    # The node exporter to collect metrics from the host
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
    };

    # The VictoriaLogs service
    services.victorialogs = {
      enable = true;
      extraOptions = [
        "-retentionPeriod=14d"
      ];
      listenAddress = "127.0.0.1:${builtins.toString cfg.logs.port}";
    };
    reverse_proxy_with_auth.services.logs = {
      subdomain = cfg.logs.subdomain;
      aclSubjects = ["user:${user.username}"];
      port = cfg.logs.port;
      routeRedirects = [
        {
          from = "/";
          to = "/select/vmui";
        }
      ];
    };
    systemd.services.victorialogs = {
      # Make sure that we don't start the journald upload
      # service if we fail to start this service.
      wantedBy = [ "systemd-journal-upload.target" ];
    };

    # Upload journald logs to VictoriaLogs
    services.journald.upload = {
      enable = true;
      settings.Upload.URL = "http://127.0.0.1:${builtins.toString cfg.logs.port}/insert/journald";
    };
    systemd.services."systemd-journal-upload" = {
      # Make sure that this only starts after
      # VictoriaLogs, otherwise it will fail to connect.
      after = [ "victorialogs.target" ];
    };

    # Grafana
    services.grafana = {
      enable = true;

      settings = {
        server.http_addr = "127.0.0.1";
        server.http_port = cfg.graphs.port;
        plugins.allow_loading_unsigned_plugins = "victoriametrics-metrics-datasource,victoriametrics-logs-datasource";
        "auth.ldap" = {
          # Note that this is "enabled" not "enable", it's a Grafana
          # option not a Nix option
          enabled = true;
          allow_sign_up = true;
          config_file = "${grafanaLdapConfig}";
        };
        database.type = "sqlite3";
        database.wal = true;
      };

      declarativePlugins = with pkgs.grafanaPlugins; [
        victoriametrics-metrics-datasource
        victoriametrics-logs-datasource
      ];

      provision.datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "VictoriaMetrics";
            type = "victoriametrics-metrics-datasource";
            access = "proxy";
            url = "http://127.0.0.1:${builtins.toString cfg.metrics.port}";
            isDefault = true;
          }
          {
            name = "VictoriaLogs";
            type = "victoriametrics-logs-datasource";
            access = "proxy";
            url = "http://127.0.0.1:${builtins.toString cfg.logs.port}";
          }
        ];
      };
    };
    reverse_proxy_with_auth.services.graphs = {
      subdomain = cfg.graphs.subdomain;
      aclSubjects = ["user:${user.username}"];
      port = cfg.graphs.port;
    };
  };
}
