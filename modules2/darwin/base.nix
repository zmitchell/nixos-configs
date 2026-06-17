{
  flake.modules.darwin.base =
    {
      config,
      pkgs,
      ...
    }:
    let
      user = config.user_profile;
    in
    {
      nix = {
        enable = true;
        package = pkgs.nixVersions.latest;
        channel.enable = false;
        settings = {
          experimental-features = "nix-command flakes";
        };
        optimise.automatic = true;
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

      users.users.${user.username}.home = "/Users/${user.username}";
    };
}
