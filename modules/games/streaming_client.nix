{pkgs, config, lib, user, ...}:
let
  # Always launch Moonlight in Wayland mode
  moonlight-wayland = pkgs.unstable.moonlight-qt.overrideAttrs ( prev: {
    buildInputs = prev.buildInputs or [] ++ [pkgs.makeWrapper];
    postInstall = prev.postInstall or "" + ''
      wrapProgram $out/bin/moonlight --set QT_QPA_PLATFORM wayland \
        --append-flags '-platform wayland'
    '';
  });
  cfg = config.games.streaming_client;
in
{
  options = {
    games.streaming_client.enable = lib.mkEnableOption "Configure the device as a game streaming client";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user.username}.home.packages = [
      moonlight-wayland
    ];
  };
}
