{
  pkgs,
  inputs,
  user,
  ...
}:
{

  # imports = [
  #   (import ./flox-remote-builders.nix (builtins.getAttr "chonker" (import ./../data/keys.nix)))
  # ];

  environment.systemPackages = with pkgs; [
    vim
    gitFull
  ];

  nix.enable = true;
  nix.channel.enable = false;
  nix.package = pkgs.nixVersions.latest;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [
    "root"
    "@admin" # necessary for Linux builder
    user.username
  ];
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enables some commands to provide completions, etc for system-provided stuff
  environment.pathsToLink = [
    "/share/man"
  ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;

  system.stateVersion = 6;
  system.primaryUser = user.username;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreeRedistributable = true;
  nixpkgs.overlays = [
    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
        config.allowUnfree = true;
      };
    })
  ];

  networking.hostName = "chonklet";

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
    };
  };

  users.users.${user.username} = {
    name = user.username;
    home = "/Users/${user.username}";
    shell = pkgs.fish;
  };

  # Dock
  system.defaults.dock = {
    autohide = true;
    mru-spaces = false;
    orientation = "left";
    persistent-apps = [
      "/System/Applications/Calendar.app"
      "/Applications/Firefox.app"
      "/Applications/Ghostty.app"
      "/Applications/Slack.app"
    ];
  };

  # Finder
  system.defaults.finder = {
    ShowPathbar = true;
    ShowStatusBar = true;
    FXPreferredViewStyle = "Nlsv"; # list view
    FXEnableExtensionChangeWarning = false;
  };

  # Trackpad
  system.defaults.trackpad = {
    TrackpadThreeFingerDrag = true;
    TrackpadRightClick = true;
  };

  # Miscellaneous
  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = false;
    AppleShowAllExtensions = true;
    "com.apple.sound.beep.volume" = 0.0;
  };
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Color schemes, fonts, etc
  stylix.enable = true;
  stylix.image = ./../wallpapers/sierra.jpg; # can be literally anything it seems on macOS
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
  };
}
