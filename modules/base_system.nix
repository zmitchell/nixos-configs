{ inputs, pkgs,  ... }:
{
  config = {
    system.stateVersion = "23.11";
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (final) system;
            config.allowUnfree = true;
          };
        })
    ];

    nix.settings.auto-optimise-store = true;
    nix.settings.experimental-features = "nix-command flakes";
    nix.settings.trusted-users = [
      "root"
      "zmitchell"
    ];

    security.sudo.wheelNeedsPassword = false;

    # Enable the OpenSSH server
    services.openssh = {
      enable = true;
      authorizedKeysInHomedir = false;
      settings = {
        # Forbid root login through SSH.
        PermitRootLogin = "no";
        # Use keys only. Remove if you want to SSH using password (not recommended)
        PasswordAuthentication = false;
      };
    };
    services.tailscale.enable = true;

    # Git config
    programs.git.enable = true;

    # Packages that should be installed on all systems
    environment.systemPackages = with pkgs; [
      binutils
      pciutils
    ];

    # Miscellaneous files we want to appear on the system
    environment.etc = {
      # Store the flake that built the system
      sourceFlake.source = builtins.path {
        name = "sourceFlake";
        # filter out `result`
        path = inputs.self;
      };
    };

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 50;
  };
}
