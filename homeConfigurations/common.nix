{pkgs, lib, user, inputs, ...}:
let
  shellAliases = import ./shell-aliases.nix;
in
{
  home.username = user.username;
  home.stateVersion = "24.05";

  home.sessionVariables.EDITOR = "hx";
  home.sessionVariables.GIT_EDITOR = "hx";
  # There's a bug for this option: https://github.com/nix-community/home-manager/issues/3417
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

  programs.git.enable = true;
  programs.git.userName = user.username;
  programs.git.userEmail = user.email;
  programs.git.extraConfig = {
    init.defaultBranch = "main";
    merge.conflictStyle = "diff3";
    rebase.autoStash = true;
    rerere.enabled = true;
  };
  programs.git.difftastic.enable = true;

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
      fish_add_path -g "$HOME/bin"
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
