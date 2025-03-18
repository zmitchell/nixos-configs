{pkgs, lib, inputs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  imports = [
    ./common.nix
  ];

  dconf.settings = {  
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };

  # Configure zsh so it's not terrible when we need to use it
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initExtra = ''
      export PATH="$HOME/bin:$PATH"
      export GIT_EDITOR="hx"

      function set-tab {
        wezterm cli set-tab-title "$1"
      }
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

  # programs.atuin.enable = false;

  programs.starship = {
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.ssh.matchBlocks = {
    chungus = {
      host = "chungus";
      hostname = "10.0.0.234";
      forwardAgent = true;
      user = user.username;
    };
    chungus-ts = {
      host = "chungus-ts";
      hostname = "chungus";
      forwardAgent = true;
      user = user.username;
    };
    smolboi = {
      host = "smolboi";
      hostname = "10.0.0.166";
      forwardAgent = true;
      user = user.username;
    };
    lad = {
      host = "lad";
      hostname = "5.78.94.2";
      forwardAgent = true;
      user = user.username;
    };
    floxci-x86-linux = {
      host = "floxci-x86-linux";
      hostname = "fd7a:115c:a1e0::22";
      user = user.username;
    };
    floxci-arm-linux = {
      host = "floxci-arm-linux";
      hostname = "fd7a:115c:a1e0::19";
      user = user.username;
    };
    floxci-x86-mac = {
      host = "floxci-x86-mac";
      hostname = "fd7a:115c:a1e0::11";
      user = user.username;
    };
    floxci-arm-mac = {
      host = "floxci-arm-mac";
      hostname = "fd7a:115c:a1e0::12";
      user = user.username;
    };
  };

}

