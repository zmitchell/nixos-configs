{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
  inputs.flox.url = "github:flox/flox";

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-index-database,
      flake-programs-sqlite,
      disko,
      home-manager,
      vscode-server,
      transg-tui,
      flox,
      ...
    }:
    let
      vmConfig =
        {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; host = "vm";};
          modules = [
            ./hosts/vm-disko.nix
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./modules
            (import ./setup/zfs_single_drive.nix {
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
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      chungusConfig =
        {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs transg-tui flox;
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            host = "chungus";
          };
          modules = [
            ./hosts/chungus.nix
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./modules
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            (import ./setup/zfs_single_drive.nix {
              device = "/dev/nvme1n1";
              user = "zmitchell";
            })
            {
              networking.hostName = "chungus";
              networking.hostId = "10042069";
            }
          ]; 
        };
      smolboiConfig =
        {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            host = "smolboi";
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [
            ./hosts/smolboi.nix
            home-manager.nixosModules.home-manager
            ./modules
            {
              networking.hostName = "smolboi";
              networking.hostId = "20042069";
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
    in {
      nixosModules = { inherit vmConfig chungusConfig smolboiConfig; };
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem self.nixosModules.vmConfig;
        smolboi = nixpkgs.lib.nixosSystem self.nixosModules.smolboiConfig;
        chungus = nixpkgs.lib.nixosSystem self.nixosModules.chungusConfig;
      };
    };
}
