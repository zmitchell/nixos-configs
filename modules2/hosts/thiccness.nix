{
  config,
  inputs,
  ...
}:
let
  # thiccness is a standalone home-manager configuration running on a
  # non-NixOS Linux host, so it can't rely on a NixOS/nix-darwin system to
  # provide packages, the user profile, or the host name.
  user = {
    fullName = "Zach Mitchell";
    username = "zmitchell";
    email = "zmitchell@halcyon.ai";
  };
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [
      (final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          localSystem = final.stdenv.hostPlatform;
          config.allowUnfree = true;
        };
      })
    ];
  };
  hm_modules = with config.flake.modules.homeManager; [
    base
    ghostty
    git
    helix
    shell
    ssh_hosts
    styles
  ];
in
{
  flake.homeConfigurations.thiccness = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      inherit inputs;
    };
    modules =
      hm_modules
      ++ [
        # Standalone home-manager needs stylix wired in directly; on the other
        # hosts this comes in through the NixOS/nix-darwin stylix module.
        inputs.stylix.homeModules.stylix
        inputs.flox.homeModules.flox
        (
          { pkgs, ... }:
          {
            # The shared home-manager modules read the host name and user
            # profile from the enclosing system config via `osConfig`. There
            # is no system config here, so provide the values they need.
            _module.args.osConfig = {
              host = "thiccness";
              user_profile = user;
            };

            home.username = user.username;
            home.homeDirectory = "/home/${user.username}";
            # Never change this
            home.stateVersion = "25.11";

            home.sessionPath = [
              "/home/${user.username}/bin"
              "/home/${user.username}/.cargo/bin"
              "/home/${user.username}/.local/bin"
            ];

            ####################################################################
            # User-level module customizations
            ####################################################################

            git = {
              gh.enable = true;
              jj.enable = true;
            };
            # No predefined SSH hosts, but still get a configured ssh client.
            ssh_hosts.hosts = { };
            shell = {
              atuin.enable = true;
              bash.enable = true;
              delta.enable = true;
              fish.enable = true;
              starship.enable = true;
              zoxide.enable = true;
              broot.enable = true;
            };
            programs.flox.enable = true;
            # The flox home-manager module writes nix.conf (cache settings),
            # which standalone home-manager only does when given a nix package.
            nix.package = pkgs.nix;

            home.packages = with pkgs; [
              sysprof
              tlp
              powertop
              marksman
              unstable.lima
              inputs.nix-auth.packages.x86_64-linux.nix-auth
            ];

            programs.fish = {
              shellAbbrs.hms = "home-manager switch --flake .#thiccness";
              loginShellInit = ''
                fish_add_path -g "$HOME/.cargo/bin"
              '';
            };
          }
        )
      ];
  };
}
