{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs @ { self, nixpkgs, flake-utils, nixos-generators, disko, ... }: 
  let 
    common = {
      modules = [
        ./stacks/users.nix
        ./stacks/system.nix
      ];
      specialArgs = { inherit inputs; };
    };
    chonkerVmConfig = {
      system = "aarch64-linux";
      specialArgs = { inherit inputs; pkgs = nixpkgs.legacyPackages.aarch64-linux; };
      modules = [
        disko.nixosModules.disko
        (import ./stacks/users.nix)
        (import ./stacks/system.nix)
        (import ./stacks/zfs_single_drive.nix {
          device = "/dev/vda";
          user = "zmitchell";
        })
        {
          networking.hostId = "deadbeef";
          # boot.loader.grub.devices=["/dev/vda"];
        }
        (import ./stacks/disko_scripts.nix)
      ];
    };
    behemothConfig = common // {
      system = "x86_64-linux";
      modules = [
        ./stacks/behemoth.nix
        # {networking.hostId = "behemoth";}
        (import ./stacks/zfs_single_drive.nix {
          device = "/dev/sda";
          user = "zmitchell";
        })
      ];
      specialArgs = { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
    };
  in
  {
    nixosModules = {
      chonker-vm = chonkerVmConfig;
      behemoth = behemothConfig;
    };
    nixosConfigurations = {
      chonker-vm = nixpkgs.lib.nixosSystem (self.nixosModules.chonker-vm // { disko.enableConfig = false; });
      behemoth = nixpkgs.lib.nixosSystem self.nixosModules.behemoth;
    };
  }
  //
  flake-utils.lib.eachDefaultSystem (system:
    {
      packages.chonkerVmInstaller = nixos-generators.nixosGenerate ({
        format = "iso";
      } // self.nixosModules.chonker-vm);
      packages.behemothInstaller = nixos-generators.nixosGenerate ({
        format = "iso";
      } // self.nixosModules.behemoth);
    }
  );
}
