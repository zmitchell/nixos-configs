{config, lib, ...}:
let
  cfg = config.desktop_audio;
in
{
  options = {
    audio.enable = lib.mkEnableOption "Enables audio on the desktop";
  };
  config = {
    hardware.pulseaudio.enable = lib.mkIf cfg.enable false;
    services.pipewire = lib.mkIf cfg.enable {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;
    };
  };
}
