{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  # Pinned for sunshine support at the moment
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
  inputs.home-manager.url = "github:nix-community/home-manager/release-25.05";
  # flox
  inputs.flox.url = "github:flox/flox/refs/tags/v1.5.1";
  # nix-darwin
  inputs.nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
  # Provides a fix for launching Nix-provided Mac apps
  inputs.mac-app-util.url = "github:hraban/mac-app-util";
  # Color schemes and fonts
  inputs.stylix.url = "github:danth/stylix/release-25.05";

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
          stylix.nixosModules.stylix
          ./modules
          ./hosts/${host}.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
              inherit inputs host user;
            };
            flox.enable = true;
            addStableBranchToRegistry.enable = true;
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
        slim = nixpkgs.lib.nixosSystem (
          mkConfig {
            system = "x86_64-linux";
            host = "slim";
            inherit user;
            extraModules = [
              {
                imports = [
                  ./hosts/slim_disk_config.nix
                ];
              }
              {
                networking.hostName = "slim";
                networking.hostId = "30042069";
                # flox.enable = nixpkgs.lib.mkForce false;
              }
            ];
          }
        );
        distant-lad = nixpkgs.lib.nixosSystem (
         mkConfig {
          system = "x86_64-linux";
          host = "distant-lad";
          inherit user;
            extraModules = [
              (import ./setup/zfs_single_drive_legacy_boot.nix {
                device = "/dev/sda";
                user = user.username;
              })
              {
                networking.hostName = "distant-lad";
                networking.hostId = "30042069";
              }
            ];
        });
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
