{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  outputs = inputs @ { self, nixpkgs, disko, ... }:
  let
    chonkerVmConfig = {
      system = "x86_64-linux";
      specialArgs = { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      modules = [
        disko.nixosModules.disko
        {
          networking.hostId= "deadbeef";
          # boot.loader.grub.devices=["/dev/vda"];
        }
        ({ config, pkgs, ... }: {
   environment.systemPackages = [
     (pkgs.runCommandCC "disko-scripts" {} ''
       mkdir -p $out/bin
       ln -s ${config.system.build.diskoScript} $out/bin/disko-script
       ln -s ${config.system.build.formatScript} $out/bin/disko-format
       ln -s ${config.system.build.mountScript} $out/bin/mount-script
       '')
   ];
 })
        (import ./zfs_single_drive.nix {
          device = "/dev/vda";
          user = "zmitchell";
        })
      ];
    };
  in
  {
    nixosModules = {
      chonker-vm = chonkerVmConfig;
    };
    nixosConfigurations = {
      chonker-vm = nixpkgs.lib.nixosSystem self.nixosModules.chonker-vm;
    };
  };
}
