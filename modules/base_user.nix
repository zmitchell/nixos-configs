{ pkgs, ... }:
let 
  gitHelpers = pkgs.callPackage ../command_sets/git.nix {};
in 
{
  config = {
    users.users.zmitchell = {
      name = "zmitchell";
      isNormalUser = true;
      initialPassword = "dumb-password";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILm7/9q3RUHuDJKih8XMWIoIFTsga2XtnOXL14CNouhd zmitchell@fastmail.com"
      ];

      # Gives the user sudo permissions
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;

      packages = with pkgs; [
        # Shell interactions
        fish
        fishPlugins.colored-man-pages
        starship
        # atuin
        zoxide
        eza
        # Utilities
        ripgrep
        fd
        just
        btop
        procs
        difftastic
        tree
        parallel
        tealdeer
        watchexec
        zellij
        # Fun stuff
        meme-image-generator
        imgcat
        # Nix stuff
        nix-index
        nix-init
        nix-tree
        nix-eval-jobs
        unstable.nixfmt-rfc-style
        # Language servers
        unstable.nil
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
    programs.command-not-found.enable = true;
  };
}
