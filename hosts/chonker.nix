{config, lib, pkgs, inputs, user, ...}:
{
  environment.systemPackages = with pkgs; [
    vim
    gitFull
  ];

  services.nix-daemon.enable = true;

  nix.package = pkgs.nixVersions.latest;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [
    "root"
    "zmitchell"
  ];
  nix.linux-builder.enable = true;
  # security.sudo.wheelNeedsPassword = false;

  # Enables some commands to provide completions, etc for system-provided stuff
  environment.pathsToLink = [
    "/share/man"
  ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;

  system.stateVersion = 4;

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

  networking.hostName = "chonker";

  users.users.${user.username} = {
    name = user.username;
    home = "/Users/${user.username}";
  };

  # Dock
  system.defaults.dock = {
    autohide = true;
    mru-spaces = false;
    orientation = "left";
    persistent-apps = [
      "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Messages.app"
      "/System/Applications/Calendar.app"
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
  system.defaults.CustomUserPreferences = {
    "/Users/${user.username}/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail.plist" = {
      "MailUserNotificationScope" = 2;
    };
  };

  # Color schemes, fonts, etc
  stylix.enable = true;
  stylix.image = ./../wallpapers/sierra.jpg; # can be literally anything it seems on macOS
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ocean.yaml";
}