{ pkgs, user, ... }:
{
  config = {
    users.users.${user.username} = {
      name = user.username;
      isNormalUser = true;
      initialPassword = "dumb-password";
      openssh.authorizedKeys.keys = [
        (builtins.getAttr "chonker" (import ../data/keys.nix))
      ];

      # Gives the user sudo permissions
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;

      packages = with pkgs; [
        # Shell interactions
        fish
        fishPlugins.colored-man-pages
        ripgrep
        btop
        procs
        tree
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
