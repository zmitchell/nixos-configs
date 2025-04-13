{pkgs, lib, config, user, ...}:
let
  cfg = config.theming;
  palettes = import ./palette_imports.nix;
  templates = import ./template_imports.nix;
in
{
  options.theming = {
    enable = lib.mkEnableOption "Enable custom theming";
    paletteName = lib.mkOption {
      type = lib.types.str;
      default = "ocean";
      description = "The name of the color palette to use";
      example = "ocean";
    };
    onlyEnable = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Only enable the theme for specific applications";
      example = [ "gtk" "ghostty" ];
    };
  };

  config = lib.mkIf cfg.enable (templates.ghostty palettes.${cfg.paletteName});
}
