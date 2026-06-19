{
  flake.modules.homeManager.ghostty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ghostty;
    in
    {
      options.ghostty = {
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

      config = {
        programs.ghostty = {
          enable = true;
          # ghostty isn't packaged for darwin in nixpkgs; install via the .dmg
          # and let home-manager only manage the config.
          package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
          settings = {
            font-family = "Hack Nerd Font Mono";
            # font-family = "Atkinson Hyperlegible Mono";
            font-size = cfg.font_size;
            font-feature = [
              "-calt"
              "-liga"
              "-dlig"
            ];
            keybind = cfg.keybinds ++ [
              # Otherwise we can have two bindings for "next tab"
              "ctrl+tab=unbind"
            ];
          };
        };
      };
    };
}
