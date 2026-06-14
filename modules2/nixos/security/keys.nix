{
  config,
  lib,
  user,
  host,
  ...
}:
let
  cfg = config.authorized_keys;
in
{
  options = {
    authorized_keys.enable = lib.mkEnableOption "Populate the authorized keys of this system with keys from all other known systems";
    allowed_hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The subset of hosts to allow access to this host.";
      example = [ "foo" "bar" ];
      # All hosts other than this one
      default = lib.attrValues (lib.filterAttrs (k: v: k != host) (import ../data/keys.nix));
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${user.username}.openssh.authorizedKeys.keys = cfg.allowed_hosts;
  };
}
