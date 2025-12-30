{config, lib, user, ...}:
with lib; let
  cfg = config.victoria;
in
{
  options.victoria = {
    enable = mkEnableOption "Enable VictoriaMetrics and VictoriaLogs, scraping the node via a Prometheus node_exporter.";
    useReverseProxy = with types; mkOption {
      type = bool;
      default = false;
      description = "Whether to serve logs/metrics behind an authenticated proxy.";
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
  };
}
