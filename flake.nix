{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";

  outputs = inputs @ { self, nixpkgs, ... }: 
  let
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
              imports = [
                ./stacks/vm-hardware-configuration.nix
              ];
            }
            ./stacks/boot.nix
            ./stacks/system.nix
            ./stacks/users.nix
            ./stacks/shell.nix
          ];
        };
  in
  {
    nixosModules = {
      inherit vmConfig;
    };
    nixosConfigurations = {
      vm = nixpkgs.lib.nixosSystem self.nixosModules.vmConfig;
    };
  };
}
