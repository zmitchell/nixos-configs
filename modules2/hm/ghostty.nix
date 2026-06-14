{config, lib, pkgs, user, ...}:
let
  cfg = config.ghostty;
in
{
  options.ghostty = {
    enable = lib.mkEnableOption "Enable Ghostty with configuration.";
    keybinds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Override my default keybindings";
      default = [
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+k=goto_split:up"
        "ctrl+shift+j=goto_split:down"
        "ctrl+t=new_tab"
        "ctrl+shift+[=previous_tab"
        "ctrl+shift+]=next_tab"
      ];
    };
    font_size = lib.mkOption {
      type = lib.types.int;
      description = "Default terminal font size.";
      default = 12;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "Hack Nerd Font Mono";
        font-size = cfg.font_size;
        font-feature = [
          "-calt"
          "-liga"
          "-dlig"
        ];
        keybind = cfg.keybinds;
      };
    };
  };
}
