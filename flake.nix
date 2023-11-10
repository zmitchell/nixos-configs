{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = inputs @ { self, nixpkgs, flake-utils, nixos-generators, ... }: 
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    common = {
      system = "x86_64-linux";
      modules = [
        ./stacks/users.nix
        ./stacks/system.nix
      ];
      specialArgs = { inherit inputs pkgs; };
    };
  in
  {
    nixosConfigurations.chonker2 = nixpkgs.lib.nixosSystem common;
  }
  //
  flake-utils.lib.eachDefaultSystem (system:
    {
      packages.chonker2-iso = nixos-generators.nixosGenerate ({
        format = "iso";
      }
      //
      common);
    }
  );

}
