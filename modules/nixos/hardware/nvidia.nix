{
  flake.modules.nixos.nvidia_gpu =
    {
      config,
      pkgs,
      ...
    }:
    {
      hardware.graphics.enable32Bit = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
      hardware.graphics.extraPackages = with pkgs; [
        nvidia-vaapi-driver
        nvidia-system-monitor-qt
      ];
    };
}
