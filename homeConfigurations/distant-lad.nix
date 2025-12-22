{pkgs, lib, inputs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  imports = [
    ./common.nix
  ];

  home.stateVersion = "24.11";

}

