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
  services.xserver.displayManager.gdm.wayland = true;

  # Applications
  programs.gnome-disks.enable = true;
  programs.gnome-terminal.enable = true;
  users.users.zmitchell.packages = with pkgs; [
    firefox
    gnome.evince # document viewer
    gnome.gedit # text editor
    gnome.eog # image viewer
    gnome.sushi # quick preview for nautilus
    gnome-console
  ] ++ [
    moonlight-wayland
  ];

  # Gaming related stuff
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };
}
