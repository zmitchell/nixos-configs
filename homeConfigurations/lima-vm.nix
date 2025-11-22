{pkgs, lib, inputs, user, ...}:
{
  imports = [
    ./common.nix
  ];
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    bacon
  ];

  programs.atuin.enable = true;
}
