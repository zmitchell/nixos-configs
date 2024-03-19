{pkgs, ...}:
let
  # Always launch Moonlight in Wayland mode
  moonlight-wayland = pkgs.moonlight-qt.overrideAttrs ( prev: {
    buildInputs = prev.buildInputs or [] ++ [pkgs.makeWrapper];
    postInstall = prev.postInstall or "" + ''
      wrapProgram $out/bin/moonlight --set QT_QPA_PLATFORM wayland
    '';
  });
in
{
  users.users.zmitchell.packages = [
    moonlight-wayland
  ];
}
