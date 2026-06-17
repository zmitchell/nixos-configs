let
  common =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.ssh;
      user = config.user_profile;
      host = config.host;
    in
    {
      options.ssh = {
        tailscale.enable = lib.mkEnableOption "Enable Tailscale on this device.";
        remote_login = {
          enable = lib.mkEnableOption "Enable remote login via SSH.";
          allowed_hosts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "The subset of hosts to allow access to this host.";
            example = [
              "foo"
              "bar"
            ];
            # All hosts (other than this one) defined in `ssh_public_keys.nix`.
            default = lib.attrValues (lib.filterAttrs (k: v: k != host) (import ./_ssh_public_keys.nix));
          };
        };
      };

      config = {
        services.tailscale.enable = lib.mkIf cfg.tailscale.enable true;

        # Enable the OpenSSH server
        services.openssh = lib.mkIf cfg.remote_login.enable {
          enable = true;
        };

        users.users.${user.username}.openssh.authorizedKeys.keys =
          lib.mkIf cfg.remote_login.enable cfg.allowed_hosts;
      };
    };
in
{
  flake.modules.nixos.ssh =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.ssh;
    in
    {
      imports = [ common ];
      config = {
        # This option doesn't exist on macOS,
        # but it makes SSH more secure since it
        # requires editing a root-owned file to
        # trust a new key.
        services.openssh = lib.mkIf cfg.remote_login.enable {
          authorizedKeysInHomeDir = false;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };
        };
      };
    };

  flake.modules.darwin.ssh = {
    imports = [ common ];
  };
}
