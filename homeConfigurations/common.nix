{config, pkgs, lib, user, host, osConfig, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  home.username = user.username;

  # There's a bug for these options: https://github.com/nix-community/home-manager/issues/3417
  home.sessionVariables.EDITOR = "hx";
  home.sessionVariables.GIT_EDITOR = "hx";
  # home.sessionPath = [
  #   "$HOME/bin"
  # ];

  home.packages = with pkgs; [
    lazygit
    zoxide
    tre-command
    ripgrep
    fd
    file
    frogmouth
    nixfmt-rfc-style
    gh-dash
    nodePackages.bash-language-server
    pyright
    tealdeer
    nix-tree
    unstable.nil
    jrnl
    nix-output-monitor
    watchexec
    fx
    unzip
    git-lfs
    parallel
    bat
    tomlq
    delta
    unstable.lazyjj
    kondo
  ];

  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.less.enable = true;
  programs.man.enable = true;

  programs.eza.enable = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.editor = "hx";
  programs.gh.settings.prompt = "enabled";
  programs.gh.settings.extensions = with pkgs; [
    gh-dash
  ];

  programs.zellij = {
    enable = true;
    settings = {
      theme = "tokyo-night";
      stacked_resize = true;
      show_startup_tips = false;
    };
  };
  home.file."${config.xdg.configHome}/zellij/layouts/default.kdl".source = ./../data/zellij_layout_default.kdl;

  programs.git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;
    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
      rebase.autoStash = true;
      rerere.enabled = true;
      push.autoSetupRemote = true;
      commit.cleanup = "strip";
      pull.ff = "only";
    };
    difftastic.enable = true;
    ignores = import ./../data/git-ignores.nix;
  };

  programs.jujutsu = {
    enable = true;
    package = pkgs.unstable.jujutsu;
    settings = {
      user = {
        email = user.email;
        name = user.fullName;
      };
      ui = {
        paginate = "never";
        default-command = ["status"];
      };
      git = {
        auto-local-bookmark = true;
        write-change-id-header = true;
      };
      revset-aliases = {
        branch = "main::@";
        "closest_pushable(to)" = "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
      };
      aliases = {
        l = ["log" "-r" "(trunk()..@):: | (trunk()..@)-"];
        lpr = ["log" "-r" "(trunk()..@):: | (trunk()..@)" "-T" "description ++ \"\n\"" "--no-graph" "--reversed"];
        tug = ["bookmark" "move" "--from" "heads(::@ & bookmarks())" "--to" "closest_pushable(@)"];
      };
      templates = {
        log_node = 
            "label(\"node\",coalesce(if(!self, label(\"elided\", \"~\")),if(current_working_copy, label(\"working_copy\", \"@\")),if(conflict, label(\"conflict\", \"×\")),if(immutable, label(\"immutable\", \"*\")),label(\"normal\", \"·\")))";
      };
    };
  };
  
  programs.yazi = {
    enable = true;
    settings.mgr = {
      linemode = "permissions";
      show_hidden = true;
    };
  };
  
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
        auto-pairs = {
          "(" = ")";
          "{" = "}";
          "[" = "]";
        };
        text-width = 100;
        soft-wrap = {
          enable = true;
          wrap-at-text-width = true;
        };
      };
      keys = {
        normal = {
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
          space.t = {
            s = [
              ":toggle soft-wrap.enable"
            ];
            w = [
              ":set whitespace.render all"
            ];
            W = [
              ":set whitespace.render none"
            ];
          };
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
        rust-analyzer.config.check = {
          command = "clippy";
          workspace = true;
          features = "all";
        };
      };
      language = [
        {
          name = "python";
          language-servers = ["pyright"];
        }
        {
          name = "markdown";
          block-comment-tokens = {
            start = "<!--";
            end = "-->";
          };
        }
        {
          name = "bash";
          file-types = [
            "bats" # the only addition, the rest are defaults
            "sh"
            "bash"
            "ash"
            "dash"
            "ksh"
            "mksh"
            "zsh"
            "zshenv"
            "zlogin"
            "zlogout"
            "zprofile"
            "zshrc"
            "eclass"
            "ebuild"
            "bazelrc"
            "Renviron"
            "zsh-theme"
            "cshrc"
            "tcshrc"
            "bashrc_Apple_Terminal"
            "zshrc_Apple_Terminal"
            { glob = "i3/config"; }
            { glob = "sway/config"; }
            { glob = "tmux.conf"; }
            { glob = ".bash_history"; }
            { glob = ".bash_login"; }
            { glob = ".bash_logout"; }
            { glob = ".bash_profile"; }
            { glob = ".bashrc"; }
            { glob = ".profile"; }
            { glob = ".zshenv"; }
            { glob = ".zlogin"; }
            { glob = ".zlogout"; }
            { glob = ".zprofile"; }
            { glob = ".zshrc"; }
            { glob = ".zimrc"; }
            { glob = "APKBUILD"; }
            { glob = ".bash_aliases"; }
            { glob = ".Renviron"; }
            { glob = ".xprofile"; }
            { glob = ".xsession"; }
            { glob = ".xsessionrc"; }
            { glob = ".yashrc"; }
            { glob = ".yash_profile"; }
            { glob = ".hushlogin"; }
          ];
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
      fixPaths = if pkgs.hostPlatform.isDarwin then ''
        # Fix nix-darwin provided paths because fish uses its own path_helper routine
        # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
        set fish_user_paths $fish_user_paths

      '' else "";
    in ''
      ${fixPaths}
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

      # Creates a new flox checkout in lieu of better Nix support for jj workspaces
      newflox = ''
        cd ~/src/flox
        jj git clone git@github.com:flox/flox.git --colocate $argv[1]
        cd $argv[1]
        nix develop --command ff b
      '';

      jjghclone = ''
        cd ~/src
        set repo_name (basename $argv[1])
        jj git clone "git@github.com:$argv[1].git" --colocate
        cd $repo_name
      '';

      y = ''
      	set tmp (mktemp -t "yazi-cwd.XXXXXX")
      	yazi $argv --cwd-file="$tmp"
      	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      		builtin cd -- "$cwd"
      	end
      	rm -f -- "$tmp"
      '';
    };
    shellAbbrs = {
      nrs = lib.mkIf pkgs.hostPlatform.isLinux "sudo nixos-rebuild switch --flake .#${host}";
      drs = lib.mkIf pkgs.hostPlatform.isDarwin "sudo darwin-rebuild switch --flake .#${host}";
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
    enableFishIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command_timeout = 5000;
      status = {
        disabled = false;
        symbol = "✘";
        pipestatus_separator = " | ";
        format = "[$status]($style)";
        pipestatus_format = "\\[ $pipestatus \\]";
        pipestatus = true;
      };
      directory.truncate_to_repo = false;
      format = pkgs.lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$nix_shell"
        "$status "
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$time"
        "$character"
      ];
    };
  };
}
