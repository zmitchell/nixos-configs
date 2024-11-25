{ config, lib, host, ... }:
let
  cfg = config.shell_config;
in
{
  options = {
    shell_config.enable = lib.mkEnableOption "Configure global shell options";
  };

  config = lib.mkIf cfg.enable {
    # Enable the fish shell
    programs.fish.enable = true;

    # Fish turns these into functions
    programs.fish.shellAliases = {
      # Directories
      cdtemp = "cd $(mktemp -d)";
    };

    # These auto-expand so you can edit them
    programs.fish.shellAbbrs = {
      nrs = "sudo nixos-rebuild switch --flake .#${host}";
      nrt = "sudo nixos-rebuild test --flake .#${host}";
    };

    # Any explicit initialization and custom settings
    programs.fish.shellInit = ''
      # Disable the greeting
      set -U fish_greeting
    '';
  };
}
