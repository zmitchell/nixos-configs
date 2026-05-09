{
  pkgs,
  user,
  inputs,
  ...
}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  imports = [
    ./common.nix
  ];
  home.stateVersion = "25.11";
  home.homeDirectory = "/home/${user.username}";
  home.sessionPath = [
    "/home/${user.username}/bin"
    "/home/${user.username}/.cargo/bin"
  ];

  home.packages = (with pkgs; [
    sysprof
    tlp
    marksman
    # inputs.flox.packages.x86_64-linux.flox
  ]) ++ [
    # inputs.flox.packages.aarch64-linux.flox
    inputs.home-manager.packages.aarch64-linux.default
  ];
  programs.fish = {
    shellAbbrs = {
      hms = "home-manager switch --flake .#chonker_vm";
      jjdiff = "jj diff --color always --context 5 | delta";
    };
  };

  programs.fish.loginShellInit = ''
    source /etc/profile.d/nix.fish
    fish_add_path -g "$HOME/.cargo/bin"
  '';

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
  };

  programs.starship = {
    enableBashIntegration = true;
  };
}
