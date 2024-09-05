{pkgs, lib, inputs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  imports = [
    ./common.nix
  ];

  # Configure zsh so it's not terrible when we need to use it
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initExtra = ''
      export PATH="$HOME/bin:$PATH"
      export GIT_EDITOR="hx"
    '';
    inherit shellAliases;
  };

  # Same for Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    inherit shellAliases;
    initExtra = ''
      shopt -s autocd
      export PATH="$HOME/bin:$PATH"
      export GIT_EDITOR="hx"
    '';
  };

  programs.zoxide = {
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
