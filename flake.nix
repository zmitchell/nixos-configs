{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
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
    inputs@{ self, nixpkgs, nix-index-database, flake-programs-sqlite, disko, ... }:
    let
      vmConfig = 
        let
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
        in {
          system = "aarch64-linux";
          specialArgs = { inherit inputs pkgs; };
          modules = [
            {
              virtualisation.vmware.guest.enable = true;
              imports = [ ./hardware/vm.nix ];
            }
            {
              networking.hostName = "nixos";
              networking.domain = "vms.home";
              networking.hostId = "00042069";
            }
            ./stacks/boot.nix
            ./stacks/system.nix
            ./stacks/users.nix
            ./stacks/shell.nix
            ./stacks/git.nix
            nix-index-database.nixosModules.nix-index
            flake-programs-sqlite.nixosModules.programs-sqlite
          ];
        };
      vmConfigDisko = 
        let
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
        in {
          system = "aarch64-linux";
          specialArgs = { inherit inputs pkgs; };
          modules = [
            {
              virtualisation.vmware.guest.enable = true;
              imports = [ ./hardware/vm-disko.nix ];
            }
            {
              networking.hostName = "nixos";
              networking.domain = "vms.home";
              networking.hostId = "10042069";
            }
            ./stacks/boot.nix
            ./stacks/system.nix
            ./stacks/users.nix
            ./stacks/shell.nix
            ./stacks/git.nix
            nix-index-database.nixosModules.nix-index
            flake-programs-sqlite.nixosModules.programs-sqlite
            (import ./stacks/zfs_single_drive.nix {
              device = "/dev/nvme0n1";
              user = "zmitchell";
            })
            disko.nixosModules.disko
          ];
        };
    in {
      nixosModules = { inherit vmConfig vmConfigDisko; };
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem self.nixosModules.vmConfig;
        vm-disko = nixpkgs.lib.nixosSystem self.nixosModules.vmConfigDisko;
      };
    };
}
