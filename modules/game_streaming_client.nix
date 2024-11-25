{pkgs, config, lib, ...}:
let
  # Always launch Moonlight in Wayland mode
  moonlight-wayland = pkgs.unstable.moonlight-qt.overrideAttrs ( prev: {
    buildInputs = prev.buildInputs or [] ++ [pkgs.makeWrapper];
    postInstall = prev.postInstall or "" + ''
      wrapProgram $out/bin/moonlight --set QT_QPA_PLATFORM wayland \
        --append-flags '-platform wayland'
    '';
  });
  cfg = config.game_streaming;
in
{
  options = {
    game_streaming.enable = lib.mkEnableOption "Configure the device as a game streaming client";
  };

  config = lib.mkIf cfg.enable {
    users.users.zmitchell.packages = [
      moonlight-wayland
    ];
  };
}
