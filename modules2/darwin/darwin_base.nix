{pkgs, user, ...}:
{
  nix = {
    enable = true;
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;
  environment.pathsToLink = [ "/share/man" ];

  system = {
    primaryUser = user.username;
    defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      "com.apple.sound.beep.volume" = 0.0;
    };
  };
}
