{
  flake.modules.nixos.xbox_controller_support =
    { config, pkgs, ... }:
    {
      boot.extraModulePackages = [
        config.boot.kernelPackages.xpadneo
      ];
      hardware.xpadneo.enable = true;
      hardware.xone.enable = true;
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
      environment.systemPackages = with pkgs; [
        xow_dongle-firmware # Xbox controller dongle firmware
      ];
    };
}
