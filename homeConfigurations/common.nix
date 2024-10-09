{pkgs, lib, user, inputs, osConfig, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  home.username = user.username;
  home.stateVersion = "24.05";

  # There's a bug for these options: https://github.com/nix-community/home-manager/issues/3417
  home.sessionVariables.EDITOR = "hx";
  home.sessionVariables.GIT_EDITOR = "hx";
  # home.sessionPath = [
  #   "$HOME/bin"
  # ];

  home.packages = with pkgs; [
    lazygit
    yazi
    zoxide
    atuin
    tre-command
    inputs.flox.packages.${pkgs.system}.default
    ripgrep
    fd
    file
    unstable.nixd
    frogmouth
    nixfmt-rfc-style
    gh-dash
    nodePackages.bash-language-server
    pyright
    tealdeer
  ];

  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.less.enable = true;
  programs.man.enable = true;

  programs.eza.enable = true;
  programs.eza.enableBashIntegration = true;
  programs.eza.enableZshIntegration = true;
  programs.eza.enableFishIntegration = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.editor = "hx";
  programs.gh.settings.prompt = "enabled";
  programs.gh.settings.extensions = with pkgs; [
    gh-dash
  ];

  programs.git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;
    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
      rebase.autoStash = true;
      rerere.enabled = true;
    };
    difftastic.enable = true;
    ignores = import ./../data/git-ignores.nix;
  };

  programs.jujutsu.enable = true;
  
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    serverAliveCountMax = 10080; # one week max
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = pkgs.unstable.helix;
    ignores = [
      "!.github/"
      "!.gitignore"
      "!.gitattributes"
    ];
    settings = {
      editor = {
        color-modes = true;
        bufferline = "multiple";
        line-number = "relative";
        rulers = [
          80
          120
        ];
        statusline.center = ["file-type"];
        statusline.right = [
          "diagnostics"
          "selections"
          "register"
          "position"
          "total-line-numbers"
          "file-encoding"
        ];
        cursor-shape.insert = "bar";
        lsp.snippets = false;
      };
      keys = {
        normal = {
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
        };
      };
    };
    languages = {
      language-server = {
        pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
          config = {};
        };
      };
      language = [
        {
          name = "python";
          language-servers = ["pyright"];
        }
        {
          name = "markdown";
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
          };
        }
      ];
    };
  };


  programs.fish = {
    enable = true;
    loginShellInit = 
    let
      # This naive quoting is good enough in this case. There shouldn't be any
      # double quotes in the input string, and it needs to be double quoted in case
      # it contains a space (which is unlikely!)
      dquote = str: "\"" + str + "\"";

      makeBinPathList = map (path: path + "/bin");
    in ''
      # Fix nix-darwin provided paths because fish uses its own path_helper routine
      # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
      set fish_user_paths $fish_user_paths

      # My actual customizations
      set -U fish_greeting # disable login message
      fish_add_path -g "$HOME/bin"
      set -gx GIT_EDITOR hx
    '';
    inherit shellAliases;
    functions = {
      # Renames the current working directory
      mvcd = ''
        set cwd $PWD
        set newcwd $argv[1]
        cd ..
        mv $cwd $newcwd
        cd $newcwd
        pwd
      '';

      # Creates a new directory and changes into it
      mkcd = ''
        mkdir -p $argv[1]
        cd $argv[1]
      '';

      set-tab = ''
        wezterm cli set-tab-title $argv[1]
      '';
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # style = "compact";
      daemon.enabled = true;
    };
    flags = [
      "--disable-up-arrow"
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command_timeout = 5000;
      directory.truncate_to_repo = false;
      format = pkgs.lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$time"
        "$status"
        "$character"
      ];
    };
  };
}
