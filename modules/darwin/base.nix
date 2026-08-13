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
          trusted-users = [
            "root"
            "@admin" # necessary for Linux builder
            user.username
          ];
        };
        optimise.automatic = true;
        linux-builder = {
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
      };
      nixpkgs.config.allowUnfree = true;

      security.pam.services.sudo_local.touchIdAuth = true;
      environment.pathsToLink = [ "/share/man" ];

      system = {
        primaryUser = user.username;
        defaults.NSGlobalDomain = {
          ApplePressAndHoldEnabled = false;
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          "com.apple.sound.beep.volume" = 0.0;
        };
      };

      users.users.${user.username}.home = "/Users/${user.username}";
    };
}
