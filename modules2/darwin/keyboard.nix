{config, lib, ...}:
let
  cfg = config.keyboard;
in
{
  options.keyboard.enable = lib.mkEnableOption "Enable keyboard configuration.";

  config = lib.mkIf cfg.enable {
    system.defaults.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
