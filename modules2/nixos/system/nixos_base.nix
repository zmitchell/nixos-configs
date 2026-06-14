{config, pkgs, lib, user, ...}:
let
  cfg = config.nixos_base;
in
{
  options.nixos_base = {
    enable = lib.mkEnableOption "Include basic system packages";
  };

  config = lib.mkIf cfg.enable {
    nix.settings.auto-optimise-store = true;
    nix.settings.experimental-features = "nix-command flakes";
    nix.settings.trusted-users = [ "root" user.username "@wheel" ];
    programs.git.enable = true;

    users.users.${user.username} = {
      name = user.username;
      isNormalUser = true;
      initialPassword = "dumb-password";

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
  };
}
