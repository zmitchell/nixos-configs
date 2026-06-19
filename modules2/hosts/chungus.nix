{
  config,
  inputs,
  ...
}:
let
  nixos_modules = with config.flake.modules.nixos; [
    # Contains the base configuration with good defaults
    nixos_interactive
    nvidia_gpu
    profiling
  ];
in
{
  flake.nixosConfigurations.chungus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixos_modules
      config.flake.modules.generic.user_profile_home
      (
        { config, pkgs, ... }:
        {
          # Never change these
          host = "chungus";
          nixpkgs.hostPlatform = "x86_64-linux";
          system.stateVersion = "25.11";

          ######################################################################
          # Hardware-level configuration
          ######################################################################
          boot = {
            initrd = {
              availableKernelModules = [
                "nvme"
                "xhci_pci"
                "ahci"
                "usb_storage"
                "usbhid"
                "sd_mod"
              ];
              kernelModules = [ ];
            };
            kernelModules = [ ];

            kernelParams = [ "module_blacklist=amdgpu" ];
          };

          filesystems = {
            "/" = {
              device = "/dev/disk/by-uuid/b08db9b4-938a-4582-9b33-c5fe48380430";
              fsType = "btrfs";
            };
            "/home" = {
              device = "/dev/disk/by-uuid/b08db9b4-938a-4582-9b33-c5fe48380430";
              fsType = "btrfs";
              options = [ "subvol=home" ];
            };
            "/home/${config.user_profile.username}/games" = {
              device = "/dev/disk/by-uuid/51816679-6159-466c-8f73-0bccccb006ef";
              fsType = "btrfs";
              options = [
                "subvol=games"
                "nofail"
                "x-systemd.device-timeout=5s"
              ];
            };
            "/nix" = {
              device = "/dev/disk/by-uuid/b08db9b4-938a-4582-9b33-c5fe48380430";
              fsType = "btrfs";
              options = [ "subvol=nix" ];
            };
            "/boot" = {
              device = "/dev/disk/by-uuid/6907-AB2C";
              fsType = "vfat";
              options = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          swapDevices = [
            { device = "/dev/disk/by-uuid/559cf400-aac1-4289-87aa-4ef8a23a71cd"; }
          ];

          ######################################################################
          # System-level module customizations
          ######################################################################

          networking.networkmanager.enable = true;
          # Unnecessary for high DPI displays
          fonts.fontconfig.hinting.enable = false;
          programs.partition-manager.enable = true;

          home-manager.users.${config.user_profile.username} = {
            # Never change this
            home.stateVersion = "24.05";

            ####################################################################
            # User-level module customizations
            ####################################################################

            ssh_hosts.hosts = {
              smolboi = {
                host = "smolboi";
                hostname = "192.168.8.166";
              };
              smolboi-ts = {
                host = "smolboi-ts";
                hostname = "smolboi";
              };
            };
          };
        }
      )
    ];
  };
}
