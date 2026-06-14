{ config, lib, pkgs, user, host, osConfig, ...}:
let
  cfg = config.shell;
  ls = "${pkgs.eza}/bin/eza";
  aliases = {
    nd = "nix develop";
    cdtemp = "cd $(mktemp -d)";
    ll = "${ls} -lh";
    lll = "${ls} -alh";
  };
in
{
  options.shell = {
    aliases.enable = lib.mkEnableOption "Enable sets of shell aliases";
    bash.enable = lib.mkEnableOption "Enables bash with customizations";
    zsh.enable = lib.mkEnableOption "Enables zsh with customizations";
    fish.enable = lib.mkEnableOption "Enables fish with customizations";
    atuin.enable = lib.mkEnableOption "Enables atuin integration in configured shells";
    zoxide.enable = lib.mkEnableOption "Enables zoxide integration in configured shells";
    starship.enable = lib.mkEnableOption "Enables starship integration in configured shells";
    delta.enable = lib.mkEnableOption "Enables the delta pager with git and jj integration.";
  };

  config = {
    programs.bash = lib.mkIf cfg.bash.enable {
      enable = true;
      enableCompletion = true;
      shellAliases = lib.mkIf cfg.aliases.enable aliases;
      initExtra = ''
        shopt -s autocd
        export PATH="$HOME/bin:$PATH"
        export GIT_EDITOR="hx"
      '';
    };

    programs.zsh = lib.mkIf cfg.zsh.enable {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;
      shellAliases = lib.mkIf cfg.aliases aliases;
      initContent = ''
        export PATH="$HOME/bin:$PATH"
        export GIT_EDITOR="hx"
      '';
    };

    programs.fish = lib.mkIf cfg.fish.enable {
      enable = true;
      loginShellInit =
        let
          # This naive quoting is good enough in this case. There shouldn't be any
          # double quotes in the input string, and it needs to be double quoted in case
          # it contains a space (which is unlikely!)
          dquote = str: "\"" + str + "\"";

          makeBinPathList = map (path: path + "/bin");
          fixPaths =
            if pkgs.hostPlatform.isDarwin then
              ''
                # Fix nix-darwin provided paths because fish uses its own path_helper routine
                # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
                fish_add_path --move --prepend --path ${
                  lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)
                }
                set fish_user_paths $fish_user_paths

              ''
            else
              "";
        in
        ''
          ${fixPaths}
          # My actual customizations
          set -U fish_greeting # disable login message
          fish_add_path -g "$HOME/bin"
          set -gx GIT_EDITOR hx
        '';
      shellAliases = lib.mkIf cfg.aliases aliases;
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

        jjghclone = {
          body = ''
            cd ~/src
            set repo_name (basename $argv[1])
            jj git clone "git@github.com:$argv[1].git" --colocate
            cd $repo_name
          '';
          description = "Clone <owner>/<name> into $PWD/<name>";
          argumentNames = "repo";
        };

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
        nrt = lib.mkIf pkgs.hostPlatform.isLinux "sudo nixos-rebuild test --flake .#${host}";
        drs = lib.mkIf pkgs.hostPlatform.isDarwin "sudo darwin-rebuild switch --flake .#${host}";
        jjdiff = "jj diff --color always --context 5 | delta";
        expush = "GIT_SSH_COMMAND=\"ssh -i ~/.ssh/id_ed25519_external\" jj git push";
      };
    };

    programs.atuin = lib.mkIf cfg.atuin.enable {
      enable = true;
      daemon.enable = true;
      enableBashIntegration = lib.mkIf cfg.bash.enable true;
      enableZshIntegration = lib.mkIf cfg.zsh.enable true;
      enableFishIntegration = lib.mkIf cfg.fish.enable true;
      flags = [
        "--disable-up-arrow"
      ];
    };

    programs.zoxide = lib.mkIf cfg.zoxide.enable {
      enable = true;
      enableBashIntegration = lib.mkIf cfg.bash.enable true;
      enableZshIntegration = lib.mkIf cfg.zsh.enable true;
      enableFishIntegration = lib.mkIf cfg.fish.enable true;
    };

    programs.starship = lib.mkIf cfg.starship.enable {
      enable = true;
      enableBashIntegration = lib.mkIf cfg.bash.enable true;
      enableZshIntegration = lib.mkIf cfg.zsh.enable true;
      enableFishIntegration = lib.mkIf cfg.fish.enable true;
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

    programs.delta = lib.mkIf cfg.delta.enable {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };

  };
}
