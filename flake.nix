{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
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

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, nix-index-database, flake-programs-sqlite, disko, ... }:
    let
      baseModules = [
        ./features/boot.nix
        ./features/system.nix
        ./features/users.nix
        ./features/shell.nix
        ./features/git.nix
        nix-index-database.nixosModules.nix-index
        flake-programs-sqlite.nixosModules.programs-sqlite
      ];
      desktopModules = [
      	./features/desktop.nix
      	./features/audio.nix
      ];
      vmConfig = 
        {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            (import ./features/zfs_single_drive.nix {
              device = "/dev/nvme0n1";
              user = "zmitchell";
            })
            {
              virtualisation.vmware.guest.enable = true;
            }
            {
              networking.hostName = "nixos";
              networking.domain = "vms.home";
              networking.hostId = "00042069";
            }
          ] ++ baseModules;
        };
      thiccboiConfig =
        {
          system = "x86_64-linux";
          specialArgs = { 
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [
            ./hosts/thiccboi.nix
            disko.nixosModules.disko
            (import ./features/zfs_single_drive.nix {
              device = "/dev/nvme1n1";
              user = "zmitchell";
            })
            {
              networking.hostName = "thiccboi";
              networking.hostId = "10042069";
            }
          ] ++ baseModules ++ desktopModules;
        };
      smolboiConfig =
        {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/smolboi.nix
            ./features/game_streaming_client.nix
            {
              networking.hostName = "smolboi";
              networking.hostId = "20042069";
            }
          ] ++ baseModules ++ desktopModules;
        };
    in {
      nixosModules = { inherit vmConfig thiccboiConfig smolboiConfig; };
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem self.nixosModules.vmConfig;
        smolboi = nixpkgs.lib.nixosSystem self.nixosModules.smolboiConfig;
        thiccboi = nixpkgs.lib.nixosSystem self.nixosModules.thiccboiConfig;
      };
    };
}
