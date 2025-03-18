{ pkgs, config, lib, ...}:
let
  cfg = config.styles;
in
{
  options = {
    styles.enable = lib.mkEnableOption "Applies custom colors, fonts, etc.";
  };
  config = lib.mkIf cfg.enable {
    stylix.enable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
    stylix.fonts = {
      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrainsMono Nerd Font Mono";
      };
    };
  };
}
