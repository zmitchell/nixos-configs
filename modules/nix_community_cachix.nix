{ pkgs, lib, config, ... }:
let
  cfg = config.nix_community_cachix;
in
{
  options.nix_community_cachix = {
    enable = lib.mkEnableOption "Installs Cachix and enables the nix-community substituter";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cachix
    ];
    nix.settings.substituters = [
      "https://nix-community.cachix.org"
    ];

    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
