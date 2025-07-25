{ config, lib, pkgs, modulesPath, ... }:
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
  # Necessary for profiling
  boot.kernel.sysctl = {
    "perf_event_paranoid" = 1;
    "perf_event_mlock_kb" = 2048;
  };
  boot.kernelParams = [ "module_blacklist=amdgpu" ];

  # Extra boot settings
  boot.loader.timeout = 0; # we have scripts for booting

  # Use a static IP address
  networking.interfaces.wlp11s0.useDHCP = false;
  networking.interfaces.eno1 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.0.0.234";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "10.0.0.1";
  networking.nameservers = [
    "1.1.1.1"
    "4.4.4.4"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.permittedInsecurePackages = [
    # I think these are from sonarr
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU settings
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
    nvidia-system-monitor-qt
  ];

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # All this bullshit was to try to get my Xbox controller working.
  # One of these things makes it work, but don't ask me which one.
  hardware.xone.enable = true;
  hardware.steam-hardware.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Privacy = "device";
      JustWorksRepairing = "always";
      FastConnectable = true;
    };
  };
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
  programs.gamemode.enable = true;

  # Sunshine game streaming server
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    # Enable nvenc support
    package = pkgs.withCudaSupport.sunshine;
  };
  
  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.perf
    vscode
    linuxHeaders
    unstable.bpftrace
    fwupd
    nixos-rebuild-ng
    xow_dongle-firmware # Xbox controller dongle firmware
  ] ++ [
    bootHelpers
  ];
  services.fwupd.enable = true;

  environment.localBinInPath = true;

  # Otherwise it often fails during switch
  systemd.services.NetworkManager-wait-online.enable = false;

  # Unnecessary for high DPI displays
  fonts.fontconfig.hinting.enable = false;
  
  # Custom modules
  # media_server.enable = true;
  generic_desktop = {
    enable = true;
    allowSleep = false;
  };
  gnome.enable = true;
  static_ip.enable = true;
  populate_authorized_keys.enable = true;
  nix_community_cachix.enable = true;
  libvirt_qemu = {
    enable = true;
    virt_manager = true;
  };

  # # Adds a specialization you can switch into for testing out hyprland.
  # specialisation = {
  #   hypr.configuration = {
  #     hyprland.enable = true;
  #   };
  # };
}
