{pkgs, lib, inputs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  imports = [ ./common.nix ];

  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    wine
    winetricks
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

  # programs.atuin.enable = false;

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
    smolboi = {
      host = "smolboi";
      hostname = "10.0.0.166";
      forwardAgent = true;
      user = user.username;
      serverAliveInterval = 60;
      serverAliveCountMax = 10080; # one week max
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

