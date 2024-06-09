{pkgs, config, lib, ...}:
let
  # Always launch Moonlight in Wayland mode
  moonlight-wayland = pkgs.moonlight-qt.overrideAttrs ( prev: {
    buildInputs = prev.buildInputs or [] ++ [pkgs.makeWrapper];
    postInstall = prev.postInstall or "" + ''
      wrapProgram $out/bin/moonlight --set QT_QPA_PLATFORM wayland
    '';
  });
  cfg = config.game_streaming_client;
in
{
  options = {
    game_streaming.enable = lib.mkEnableOption "Configure the device as a game streaming client";
  };

  config = {
    users.users.zmitchell.packages = lib.mkIf cfg.enable [
      moonlight-wayland
    ];
  };
}
