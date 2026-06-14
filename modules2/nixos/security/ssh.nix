{config, lib, ...}:
let
  cfg = config.tailscale;
in
{
  options.tailscale = {
    enable = lib.mkEnableOption "Enable Tailscale on this machine";
  };

  config = {
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
    services.tailscale.enable = cfg.enable;
  };
}
