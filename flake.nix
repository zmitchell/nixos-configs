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
                ./hardware/vm.nix
              ];
            }
            {
              networking.hostName = "nixos";
              networking.domain = "vms.home";
            }
            ./stacks/boot.nix
            ./stacks/system.nix
            ./stacks/users.nix
            ./stacks/shell.nix
            ./stacks/git.nix
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
