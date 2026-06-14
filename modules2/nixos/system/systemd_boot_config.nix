{ config, lib, ... }:
let
  cfg = config.systemd_boot_config;
in
{
  options.systemd_boot_config = {
    enable = lib.mkEnableOption "Configure modern boot settings with systemd-boot and UEFI";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 10;
  };
}
