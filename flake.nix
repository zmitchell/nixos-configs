{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  # Used to get pre-built databases for 'nix-index',
  inputs.nix-index-database.url = "github:Mic92/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  # For fixing the 'command-not-found' script that's broken on flake-based systems
  inputs.flake-programs-sqlite.url = "github:wamserma/flake-programs-sqlite";
  inputs.flake-programs-sqlite.inputs.nixpkgs.follows = "nixpkgs";
  # Declarative filesystem setup
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  # Home manager
  inputs.home-manager.url = "github:nix-community/home-manager/release-24.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  # Fix for using VS Code remotely
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  # Hyprland
  inputs.hyprland.url = "github:hyprwm/Hyprland";
  # transmission tui
  inputs.transg-tui.url = "github:PanAeon/transg-tui";
  # flox
  inputs.flox.url = "github:flox/flox/v1.3.5";
  # nix-darwin
  inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  # Provides a fix for launching Nix-provided Mac apps
  inputs.mac-app-util.url = "github:hraban/mac-app-util";
  # inputs.mac-app-util.inputs.nixpkgs.follows = "nixpkgs"; # a dependency is broken on 24.05
  # Color schemes and fonts
  inputs.stylix.url = "github:danth/stylix/release-24.05";
  # inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  # Bug in upstream base16.nix that hasn't been backported to release-24.05 stylix branch
  # inputs.stylix.inputs.base16.follows = "base16";
  # inputs.base16.url = "github:SenchoPens/base16.nix?ref=refs/pull/19/head";

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-index-database,
      flake-programs-sqlite,
      disko,
      home-manager,
      nix-darwin,
      stylix,
      mac-app-util,
      vscode-server,
      transg-tui,
      flox,
      ...
    }:
    let
      mkConfig = { system, host, user, extraModules }: {
        inherit system;
        specialArgs = {
          inherit inputs host user;
        };
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          # There's a bug in stylix at the moment
          # stylix.nixosModules.stylix
          ./modules
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
              inherit inputs host user;
            };
            flox.enable = true;
          }
          ({user, host, ...}: {
            home-manager.users.${user.username} = import ./homeConfigurations/${host}.nix;
          })
        ] ++ extraModules;
      };
      user = {
        fullName = "Zach Mitchell";
        username = "zmitchell";
        email = "zmitchell@fastmail.com";
      };
    in {
      nixosConfigurations = {
        smolboi = nixpkgs.lib.nixosSystem (
         mkConfig {
          system = "x86_64-linux";
          host = "smolboi";
          inherit user;
          extraModules = [
            ./hosts/smolboi.nix
            {
              networking.hostName = "smolboi";
              networking.hostId = "20042069";
            }
          ];
        });
        chungus = nixpkgs.lib.nixosSystem (
          mkConfig {
            system = "x86_64-linux";
            host = "chungus";
            inherit user;
            extraModules = [
              ./hosts/chungus.nix
              (import ./setup/zfs_single_drive.nix {
                device = "/dev/nvme1n1";
                user = "zmitchell";
              })
              {
                networking.hostName = "chungus";
                networking.hostId = "10042069";
              }
            ];
          }
        );
      };
      darwinConfigurations = {
        chonker = nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/chonker.nix
            ./modules/flox.nix
            home-manager.darwinModules.home-manager
            mac-app-util.darwinModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.zmitchell = import ./homeConfigurations/chonker.nix;
              home-manager.extraSpecialArgs = { inherit user inputs; host = "chonker"; };
              flox.enable = true;
            }
            stylix.darwinModules.stylix
            ({ pkgs, config, inputs, ... }: {
                home-manager.sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];
            })
          ];
          specialArgs = { inherit user inputs; host = "chonker"; };
        };
      };
    };
}
