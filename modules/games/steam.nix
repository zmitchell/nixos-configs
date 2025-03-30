{pkgs, lib, config, ...}:
let
  cfg = config.games.steam;
in
{
  options.games.steam = {
    enable = lib.mkEnableOption "Install and configure Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        # Fork of upstream Proton with extra patches not yet upstreamed
        proton-ge-bin
      ];
    };
    # Allow Steam to detect hardware changes i.e. controllers being added
    hardware.steam-hardware.enable = true;
    programs.gamemode.enable = true;
  };
}
