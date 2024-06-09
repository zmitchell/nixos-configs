{config, lib, ...}:
let
  cfg = config.services.monitoring;
in
{
  options = {
		services.monitoring = {
			enable = lib.mkEnableOption "Enables monitoring services";

			grafana = {
				port = lib.mkOption {
					type = lib.types.port;
					default = 3000;
					description = lib.mdDoc "Port for the Grafana web interface";
				};
			};

			prometheus = {
				port = lib.mkOption {
					type = lib.types.port;
					default = 9001;
					description = lib.mdDoc "Port for the Prometheus server";
				};
				zfs.enable = lib.mkEnableOption "Enables ZFS filesystem reporting";
			};
		};
	};
	config = {
		services.prometheus = lib.mkIf cfg.enable {
			enable = true;
			exporters = {
				node = {
					enable = true;
					enabledCollectors = [
					  "systemd"
						(lib.mkIf cfg.prometheus.zfs.enable "zfs")
					];
				};
			};
			port = cfg.prometheus.port;
			scrapeConfigs = [
				{
					job_name = "node_scrape";
					static_configs = [{
						targets = [
							"127.0.0.1:${builtins.toString config.services.prometheus.exporters.node.port}"
						];
					}];
				}
			];
		};
		services.grafana = lib.mkIf cfg.enable {
			enable = true;
			settings.server.domain = "0.0.0.0";
			settings.server.http_port = cfg.grafana.port;
			provision = {
				enable = true;
				datasources.settings.datasources = [
					{
						name = "prometheus";
						type = "prometheus";
						url = "localhost:${builtins.toString config.services.prometheus.port}";
						isDefault = true;
					}
				];
			};
		};
	 #  networking.firewall.allowedTCPPorts = [
		# 	cfg.grafana.port
		# ];
	};
}
