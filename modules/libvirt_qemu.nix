{config, lib, pkgs, user, ...}:
with lib; let
  cfg = config.libvirt_qemu;
in
{
	options.libvirt_qemu = {
		enable = mkEnableOption "Enable libvirtd and configure it with QEMU support.";
		virt_manager = with types; mkOption {
			type = bool;
			description = "Install virt-manager along with libvirt and qemu.";
			default = false;
		};
	};

	config = mkIf cfg.enable {
		programs.virt-manager.enable = cfg.virt_manager;
		users.groups.libvirtd.members = [user.username];
		virtualisation.libvirtd.enable = true;
		virtualisation.spiceUSBRedirection.enable = true;
		environment.systemPackages = with pkgs; [
			quickemu
		];
	};
}
