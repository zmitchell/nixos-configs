{ pkgs, ... }:
let gitHelpers = pkgs.callPackage ../command_sets/git.nix { };
in {
  users.users.zmitchell = {
    name = "zmitchell";
    isNormalUser = true;

    # Gives the user sudo permissions
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;

    packages = with pkgs; [
      # Shell interactions
      fish
      fishPlugins.colored-man-pages
      starship
      atuin
      zoxide
      eza
      # Utilities
      ripgrep
      fd
      just
      btop
      difftastic
      # Fun stuff
      meme-image-generator
      imgcat
      # Nix stuff
      nix-index
      nix-init
      nix-tree
      nix-eval-jobs
      nixfmt
      # Language servers
      nil
      nodePackages.bash-language-server
      # Command sets
      gitHelpers
    ];
  };

  environment.variables.EDITOR = pkgs.helix.meta.mainProgram;

  # 'nix-index' enables these by default, even though they're mutually exclusive
  # with the default  'programs.command-not-found.enable'.
  # That particular program is broken on flake-based systems anyway, but I'm using
  # 'flake-programs-sqlite' to solve that issue.
  programs.nix-index.enableFishIntegration = false;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;
}
