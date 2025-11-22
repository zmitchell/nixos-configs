{config, lib, pkgs, inputs, user, ...}:
{
  
  # imports = [
  #   (import ./flox-remote-builders.nix (builtins.getAttr "chonker" (import ./../data/keys.nix)))
  # ];
 
  environment.systemPackages = with pkgs; [
    vim
    gitFull
    lima
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
  nix.linux-builder.enable = true;
  nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
  nix.settings.trusted-public-keys = [
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    # Public key for my private catalog
    "signing-key:a7ifhEZBmx+mP+z6cDgcBQzTZmtjHssCFkWWyI1dApg="
    # Meetrlyio catalog key
    "floxhub-meetrlyio-1:UVrkk/hwRCX8DEjrYF+2JjVP2ad3KUeya/1C5b3lsR8="
  ];

  # Enables some commands to provide completions, etc for system-provided stuff
  environment.pathsToLink = [
    "/share/man"
  ];
 
  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.bash.enable = true;

  system.stateVersion = 4;
  system.primaryUser = user.username;
  ids.gids.nixbld = 350;

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
    shell = pkgs.fish;
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
  # This path definitely exists, but `defaults` says it doesn't.
  # Might be a permissions issue.
  # system.defaults.CustomUserPreferences = {
  #   "/Users/${user.username}/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail.plist" = {
  #     "MailUserNotificationScope" = 2;
  #   };
  # };

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
