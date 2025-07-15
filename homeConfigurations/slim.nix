{pkgs, lib, inputs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  imports = [
    ./common.nix
  ];
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    signal-desktop
    todoist-electron
    spotify
    spot # spotify client that doesn't look like ass
    bustle
    d-spy
    unstable.logseq
    mpv
    forge-sparks
    curtail
    sysprof
    tlp
    powertop
    vesktop
  ];

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Hack Nerd Font Mono";
      font-size = 14;
      font-feature = [ "-calt" "-liga" "-dlig" ];
    };
  };

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
    '';
  };

  programs.zoxide = {
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
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
  };

}


