{pkgs, lib, user, inputs, ...}:
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
    zoxide
    atuin
    tre
    inputs.flox.packages.${pkgs.system}.default
    ripgrep
    fd
    file
    unstable.nixd
    frogmouth
    nixfmt-rfc-style
    gh-dash
  ];

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
    userName = user.username;
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

  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.less.enable = true;
  programs.man.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = pkgs.unstable.helix;
  };

  programs.wezterm.enable = true;

  programs.fish = {
    enable = true;
    loginShellInit = ''
      set fish_greeting # disable login message
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
    };
  };
}
