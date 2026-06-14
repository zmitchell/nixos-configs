{config, lib, ...}:
let
  cfg = config.finder;
in
{
  options.finder.enable = lib.mkEnableOption "Enable finder configuration.";

  config = lib.mkIf cfg.enable {
    system.defaults.finder = {
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXEnableExtensionChangeWarning = false;
    };
  };
}
