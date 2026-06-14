{config, lib, ...}:
let
  cfg = config.zellij;
in
{
  options.zellij = {
    enable = lib.mkEnableOption "Enabled zellij with configuration.";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "tokyo-night";
        stacked_resize = true;
        show_startup_tips = false;
      };
    };
    home.file."${config.xdg.configHome}/zellij/layouts/default.kdl".source =
      ./../data/zellij_layout_default.kdl;
  };
}
