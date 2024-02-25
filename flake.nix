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
  # Used to generate installer ISOs
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    inputs@{ self, nixpkgs, nix-index-database, flake-programs-sqlite, disko, nixos-generators, ... }:
    let
      baseModules = [
        ./stacks/boot.nix
        ./stacks/system.nix
        ./stacks/users.nix
        ./stacks/shell.nix
        ./stacks/git.nix
        nix-index-database.nixosModules.nix-index
        flake-programs-sqlite.nixosModules.programs-sqlite
      ];
      vmConfig = 
        let
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
        in
          {
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
            ] ++ baseModules;
          };
      thiccboiConfig =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
          {
            system = "x86_64-linux";
            specialArgs = { inherit inputs pkgs; };
            modules = [
              {
                networking.hostName = "thiccboi";
                networking.hostId = "10042069";
              }
            ] ++ baseModules;
          };
      thiccboiInstaller =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
          {
            system = "x86_64-linux";
            specialArgs = { inherit inputs pkgs; };
            modules = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              {
                networking.hostName = "thiccboi";
                networking.hostId = "10042069";
              }
              {
                services.openssh.settings.PermitRootLogin = nixpkgs.lib.mkForce "yes";
              }
            ] ++ baseModules;
        };
      smolboiConfig =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
          {
            system = "x86_64-linux";
            specialArgs = { inherit inputs pkgs; };
            modules = [
	      ./hardware/smolboi.nix
              {
                networking.hostName = "smolboi";
                networking.hostId = "20042069";
              }
              ./stacks/desktop.nix
            ] ++ baseModules;
          };
    in {
      nixosModules = { inherit vmConfig thiccboiConfig thiccboiInstaller smolboiConfig; };
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem self.nixosModules.vmConfig;
        smolboi = nixpkgs.lib.nixosSystem self.nixosModules.smolboiConfig;
        thiccboi = nixpkgs.lib.nixosSsytem self.nixosModules.thiccboiConfig;
        thiccboiInstaller = nixpkgs.lib.nixosSystem self.nixosModules.thiccboiInstaller;
      };
    };
}
