{pkgs, lib, config, ...}:
let
  cfg = config.games.xbox_controller;
in
{
  options.games.xbox_controller = {
    enable = lib.mkEnableOption "Enable Xbox controller input";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      config.boot.kernelPackages.xpadneo
    ];
    hardware.xpadneo.enable = true;
    hardware.xone.enable = true;
    hardware.steam-hardware.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Privacy = "device";
        JustWorksRepairing = "always";
        FastConnectable = true;
      };
    };
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
  };
}
