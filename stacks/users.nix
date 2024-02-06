{
  pkgs,
  ...
}:
let
  gitHelpers = pkgs.callPackage ../command_sets/git.nix {};
in
  {
    users.users.zmitchell = {
      name = "zmitchell";
      isNormalUser = true;

      # Gives the user sudo permissions
      extraGroups = ["wheel"];
      shell = pkgs.fish;

      packages = with pkgs; [
        # Packages
        fish
        fishPlugins.colored-man-pages
        starship
        ripgrep
        fd
        just
        atuin
        zoxide
        eza
        # System wide language servers
        nil
        nodePackages.bash-language-server
      ] ++ [
        # Command sets
        gitHelpers
      ];
    };

    environment.variables.EDITOR = pkgs.helix;
  }
