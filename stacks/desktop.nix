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
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.gnome-disks.enable = true;
  programs.gnome-terminal.enable = true;

  users.users.zmitchell.packages = with pkgs; [
    firefox
    gnome.evince # document viewer
    gnome.gedit # text editor
    gnome.eog # image viewer
    gnome.sushi # quick preview for nautilus
  ] ++ [
    moonlight-wayland
  ];

  # Gaming related stuff
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;
}
