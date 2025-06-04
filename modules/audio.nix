{config, lib, ...}:
let
  cfg = config.desktop_audio;
in
{
  options = {
    desktop_audio.enable = lib.mkEnableOption "Enables audio on the desktop";
  };
  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;
    };
  };
}
