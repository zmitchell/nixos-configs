{
  config,
  lib,
  pkgs,
  modulesPath,
  user,
  ...
}:
let
  bootHelpers = pkgs.callPackage ../command_sets/boot.nix { };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
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

  networking.networkmanager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b08db9b4-938a-4582-9b33-c5fe48380430";
      fsType = "btrfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/b08db9b4-938a-4582-9b33-c5fe48380430";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/home/${user.username}/games" =
    { device = "/dev/disk/by-uuid/51816679-6159-466c-8f73-0bccccb006ef";
      fsType = "btrfs";
      options = [
        "subvol=games"
        "nofail"
        "x-systemd.device-timeout=5s"
      ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/b08db9b4-938a-4582-9b33-c5fe48380430";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6907-AB2C";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/559cf400-aac1-4289-87aa-4ef8a23a71cd"; }
    ];


  # GPU settings
  hardware.graphics.enable32Bit = true;
  services.xserver.videoDrivers = [ "nvidia" ];
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

  environment.systemPackages =
    with pkgs;
    [
      perf
      vscode
      linuxHeaders
      unstable.bpftrace
      fwupd
      xow_dongle-firmware # Xbox controller dongle firmware
    ]
    ++ [
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
  services.xserver.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # gnome.enable = true;

  # static_ip.enable = true;
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
  programs.partition-manager.enable = true;
}
