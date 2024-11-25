{pkgs, config, lib, inputs, user, ...}:
let
  cfg = config.flox;
in
{
	options = {
    flox.enable = lib.mkEnableOption "Install Flox";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user.username}.home.packages = [
      inputs.flox.packages.${pkgs.system}.default
    ];
    
    # Add the Flox substituters
    nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
    nix.settings.trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
  };
}
