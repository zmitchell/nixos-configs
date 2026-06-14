{config, lib, ...}:
let
  cfg = config.dock;
in
{
  options.dock = {
    enable = lib.mkEnableOption "Enable dock configuration";
    apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The names (not including `.app`) of the Applications to pin to the dock.";
      example = [ "Messages" "Calendar" "Signal" ];
    };
  };

  config = lib.mkIf cfg.enable {
    system.defaults.dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "left";
      persistent-apps = lib.map (name: "/System/Applications/${name}.app") cfg.apps;
    };
  };
}
