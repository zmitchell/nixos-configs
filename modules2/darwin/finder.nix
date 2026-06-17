{
  flake.modules.darwin.finder = {
    system.defaults.finder = {
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXEnableExtensionChangeWarning = false;
    };
  };
}
