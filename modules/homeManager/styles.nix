{
  flake.modules.homeManager.styles =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.styles;
      wallpaperRoot = ./../../wallpapers;
    in
    {
      options.styles = {
        background = lib.mkOption {
          type = lib.types.path;
          default = lib.path.append wallpaperRoot "grayscale-desert.jpg";
          description = "Path to an image to set as the background.";
        };
        color_scheme = lib.mkOption {
          type = lib.types.str;
          description = "A base16 color scheme name to apply.";
          default = "ocean";
        };
      };

      config.stylix = {
        image = cfg.background;
        targets = {
          bat.enable = true;
          btop.enable = true;
          fish.enable = true;
          fzf.enable = true;
          helix.enable = true;
          wezterm.enable = true;
          yazi.enable = true;
          zellij.enable = true;
        };
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.color_scheme}.yaml";
        # fonts.monospace = {
        #   package = pkgs.nerd-fonts.jetbrains-mono;
        #   name = "JetBrainsMono Nerd Font Mono";
        # };
        fonts.monospace = {
          package = pkgs.nerd-fonts-atkynson-mono;
          name = "Atkinson Hyperlegible Mono";
        };
      };
    };
}
