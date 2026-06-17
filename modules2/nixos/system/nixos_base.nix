{
  flake.modules.nixos.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.nixos_base;
      user = config.user_profile;
    in
    {
      options.nixos_base = {
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          description = "The most basic set of packages to include on the system.";
          default = with pkgs; [
            fish
            fishPlugins.colored-man-pages
            ripgrep
            btop
            procs
            tre-command
            yazi
            helix
            fd
            jq
            fx
          ];
        };
        sudoNeedsPassword = lib.mkOption {
          type = lib.types.bool;
          description = "Whether sudo requires a password.";
          default = false;
        };
      };

      config = {
        nix.settings.auto-optimise-store = true;
        nix.settings.experimental-features = "nix-command flakes";
        nix.settings.trusted-users = [
          "root"
          user.username
          "@wheel"
        ];
        programs.git.enable = true;
        environment.systemPackages = cfg.packages;
        security.sudo.wheelNeedsPassword = cfg.sudoNeedsPassword;

        users.users.${user.username} = {
          name = user.username;
          isNormalUser = true;
          initialPassword = "dumb-password";

          # Gives the user sudo permissions
          extraGroups = [ "wheel" ];
          shell = pkgs.fish;
        };

        environment.variables.EDITOR = pkgs.helix.meta.mainProgram;
      };
    };
}
