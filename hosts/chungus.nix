
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, flox, ... }:
let
    bootHelpers = pkgs.callPackage ../command_sets/boot.nix {};
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Extra boot settings
  boot.loader.timeout = 0; # we have scripts for booting

  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp11s0.useDHCP = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU settings
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
  hardware.opengl.extraPackages = with pkgs; [
    nvidia-vaapi-driver
    nvidia-system-monitor-qt
  ];
  
  environment.systemPackages = with pkgs; [
    vscode
    sublime-merge
    linuxHeaders
    # unstable.logseq
  ] ++ [
    bootHelpers
    flox.packages.x86_64-linux.flox
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  environment.localBinInPath = true;
  
  # Pre-populate SSH keys from other machines
  users.users.zmitchell.openssh.authorizedKeys.keys = pkgs.lib.attrValues (
    pkgs.lib.filterAttrs (k: v: k != "chungus") (import ../data/keys.nix));

  media_server.enable = true;
  gnome.enable = true;
}
