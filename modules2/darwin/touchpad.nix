{config, lib, ...}:
let
  cfg = config.trackpad;
in
{
  options.trackpad.enable = lib.mkEnableOption "Enable trackpad configuration.";

  config = lib.mkIf cfg.enable {
    system.defaults.trackpad = {
      TrackpadThreeFingerDrag = true;
      TrackpadRightClick = true;
    };
  };
}
