{ pkgs, config, lib, user, ...}:
let
  cfg = config.styles;
  wallpaperRoot = ./../wallpapers;
in
{
  options.styles = {
    enable = lib.mkEnableOption "Applies custom colors, fonts, etc.";
    background = lib.mkOption {
      type = lib.types.path;
      default = lib.path.append wallpaperRoot "grayscale-desert.jpg";
      description = "Path to an image to set as the background";
    };
  };
  config = lib.mkIf cfg.enable {
    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
      polarity = "light";
      image = cfg.background;
      autoEnable = false;
      targets = {
        console.enable = true;
      };
    };
    home-manager.users.${user.username}.stylix = {
      targets = {
        bat.enable = true;
        btop.enable = true;
        fish.enable = true;
        fzf.enable = true;
        helix.enable = true;
        yazi.enable = true;
        wezterm.enable = true;
        zellij.enable = true;
      };
      fonts = {
        serif = {
          package = pkgs.unstable.aleo-fonts;
          name = "Aleo";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        monospace = {
          package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
          name = "JetBrainsMono Nerd Font Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          desktop = 12;
          applications = 12;
          terminal = 13;
          popups = 12;
        };
      };
    };
  };
}
