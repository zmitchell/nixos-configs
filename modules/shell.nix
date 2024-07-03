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
      # 'ls' stuff
      ls = "eza -1";
      lsall = "eza -al --total-size --smart-group --time-style long-iso";
      # git-related aliases
      gs = "git status";
      gl = "git log --oneline";
      gp = "git push";
      gc = "git commit -m $1";
      ga = "git add .";
      # Launch an editor for config files
      sshconfig = "$EDITOR ~/.ssh";
      # Directories
      cdtemp = "cd $(mktemp -d)";
    };

    # These auto-expand so you can edit them
    programs.fish.shellAbbrs = {
      nrs = "sudo nixos-rebuild switch --flake .#${host}";
      nrt = "sudo nixos-rebuild test --flake .#${host}";
    };

    # Shell prompt, search, etc
    # services.atuin.enable = true;
    programs.starship.enable = true;
    programs.starship.settings = {
      command_timeout = 3000;
      nix_shell.heuristic = true;
      directory.truncate_to_repo = false;
    };

    # Any explicit initialization and custom settings
    programs.fish.shellInit = ''
      # Disable the greeting
      set -U fish_greeting
      
      # Initialize shell programs
      # atuin init fish --disable-up-arrow | source
      zoxide init fish | source
    '';
  };
}
