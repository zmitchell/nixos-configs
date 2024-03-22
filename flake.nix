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
  # Home manager
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  # Fix for using VS Code remotely
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";
  # Hyprland
  inputs.hyprland.url = "github:hyprwm/Hyprland";
  # inputs.hyprland.inputs.nixpkgs.follows = "nixpkgs";

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
      ...
    }:
    let
      baseModules = [
        ./features/boot.nix
        ./features/system.nix
        ./features/users.nix
        ./features/shell.nix
        ./features/git.nix
        nix-index-database.nixosModules.nix-index
        flake-programs-sqlite.nixosModules.programs-sqlite
        vscode-server.nixosModules.default
        ({...}: {home-manager.users.zmitchell.home.stateVersion = "23.11";})
        ({...}: {services.vscode-server.enable = true;})
      ];
      gnomeDesktopModules = [
      	./features/desktop_generic.nix
        ./features/desktop_gnome.nix
      	./features/audio.nix
      ];
      hyprlandDesktopModules = [
        ./features/desktop_generic.nix
        ./features/desktop_hyprland.nix
        ./features/audio.nix
      ];
      vmConfig =
        {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; host = "vm";};
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
      chungusConfig =
        {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            host = "chungus";
          };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            ./hosts/chungus.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            (import ./features/zfs_single_drive.nix {
              device = "/dev/nvme1n1";
              user = "zmitchell";
            })
            {
              networking.hostName = "chungus";
              networking.hostId = "10042069";
            }
          ] ++ baseModules ++ hyprlandDesktopModules;
        };
      smolboiConfig =
        {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; host = "smolboi";};
          modules = [
            ./hosts/smolboi.nix
            ./features/game_streaming_client.nix
            {
              networking.hostName = "smolboi";
              networking.hostId = "20042069";
            }
          ] ++ baseModules ++ gnomeDesktopModules;
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
