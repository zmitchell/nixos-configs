{
  pkgs,
  user,
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

  home.packages = with pkgs; [
    bustle
    d-spy
    sysprof
    tlp
    powertop
    zeal
  ];
  programs.fish = {
    shellAbbrs = {
      hms = "home-manager switch --flake .#thiccness";
      jjdiff = "jj diff --color always --context 5 | delta";
    };
  };

  programs.fish.loginShellInit = ''
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
