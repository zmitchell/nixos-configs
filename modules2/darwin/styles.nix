{config, pkgs, lib, ...}:
let
  cfg = config.styles;
in
{
  options.styles.enable = lib.mkEnableOption "Enable custom styles.";

  config = lib.mkIf cfg.enable {
    stylix.enable = true;
    stylix.image = ./../../wallpapers/sierra.jpg; # can be literally anything it seems on macOS
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
    stylix.fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
    };
  };
}
