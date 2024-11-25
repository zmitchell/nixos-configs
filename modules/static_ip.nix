{config, lib, host, ...}:
let
	ipCfg = builtins.getAttr host (import ../data/static_ips.nix);
  cfg = config.static_ip;
in
{
	options = {
		static_ip.enable = lib.mkEnableOption "Set a static IP address for this host";
	};

	config = lib.mkIf cfg.enable {
		networking.interfaces.${ipCfg.interface}.ipv4.addresses = [
			{
				address = ipCfg.address;
				prefixLength = 24;
			}
		];
	};
}
