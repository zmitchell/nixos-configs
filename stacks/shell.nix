{ ... }: {
  # Enable the fish shell
  programs.fish.enable = true;

  programs.fish.shellAliases = {
    # 'ls' stuff
    ls = "eza -1";
    lsall = "eza -al --total-size --smart-group --time-style long-iso";
    # git-related aliases
    gs = "git status";
    gl = "git log --oneline";
    gp = "git push";
    # Launch an editor for config files
    sshconfig = "$EDITOR ~/.ssh";
  };
  services.atuin.enable = true;
  programs.fish.shellInit = ''
    # Disable the greeting
    set -U fish_greeting
    
    # Initialize shell programs
    atuin init fish --disable-up-arrow | source
    zoxide init fish | source
  '';

  # Starship settings
  programs.starship.enable = true;
  programs.starship.settings = {
    command_timeout = 3000;
    nix_shell.heuristic = true;
    directory.truncate_to_repo = false;
  };
}
