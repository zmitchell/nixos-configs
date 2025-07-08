{pkgs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
  deploy-config = pkgs.callPackage ../pkgs/deploy-config/default.nix {};
in
{
  imports = [
    ./common.nix
  ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    bacon
    utm
    unstable.kitty
    podman
    clamav
  ] ++ [
    deploy-config
  ];

  # Configure zsh so it's not terrible when we need to use it
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
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

      function set-tab {
        wezterm cli set-tab-title "$1"
      }
    '';
  };

  programs.atuin.enable = true;

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

  programs.ssh.matchBlocks = {
    chungus = {
      host = "chungus";
      hostname = "10.0.0.234";
      forwardAgent = true;
      user = user.username;
      setEnv = {
        # Fix for ghostty
        TERM = "xterm-256color";
      };
    };
    chungus-ts = {
      host = "chungus-ts";
      hostname = "chungus";
      forwardAgent = true;
      user = user.username;
      setEnv = {
        # Fix for ghostty
        TERM = "xterm-256color";
      };
    };
    smolboi = {
      host = "smolboi";
      hostname = "10.0.0.166";
      forwardAgent = true;
      user = user.username;
      setEnv = {
        # Fix for ghostty
        TERM = "xterm-256color";
      };
    };
    smolboi-ts = {
      host = "smolboi-ts";
      hostname = "smolboi";
      forwardAgent = true;
      user = user.username;
      setEnv = {
        # Fix for ghostty
        TERM = "xterm-256color";
      };
    };
    lad = {
      host = "lad";
      hostname = "5.78.94.2";
      forwardAgent = true;
      user = user.username;
      setEnv = {
        # Fix for ghostty
        TERM = "xterm-256color";
      };
    };
  };
}
