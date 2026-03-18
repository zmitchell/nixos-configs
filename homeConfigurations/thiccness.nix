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

  home.packages = with pkgs; [
    bustle
    d-spy
    sysprof
    tlp
    powertop
    zeal
  ];

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Hack Nerd Font Mono";
      font-size = 12;
      font-feature = [
        "-calt"
        "-liga"
        "-dlig"
      ];
      keybind = [
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+k=goto_split:up"
        "ctrl+shift+j=goto_split:down"
        "ctrl+t=new_tab"
        "ctrl+shift+[=previous_tab"
        "ctrl+shift+]=next_tab"
      ];
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
