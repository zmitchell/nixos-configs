{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = inputs @ { self, nixpkgs, flake-utils, nixos-generators, ... }: 
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
      specialArgs = { pkgs = nixpkgs.legacyPackages.aarch64-linux; };
    } // common;
    behemothConfig = {
      system = "x86_64-linux";
      modules = [
        ./stacks/behemoth.nix
      ];
      specialArgs = { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
    } // common;
  in
  {
    nixosModules = {
      chonker-vm = chonkerVmConfig;
      behemoth = behemothConfig;
    };
    nixosConfigurations = {
      chonker-vm = nixpkgs.lib.nixosSystem self.nixosModules.chonker-vm;
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
