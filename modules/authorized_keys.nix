{config, lib, user, host, ...}:
let
  cfg = config.populate_authorized_keys;
in
{
  options = {
    populate_authorized_keys.enable = lib.mkEnableOption "Populate the authorized keys of this system with keys from all other known systems";
  };

  config = lib.mkIf cfg.enable {
    # Pre-populate SSH keys from other machines
    users.users.${user.username}.openssh.authorizedKeys.keys = lib.attrValues (
      lib.filterAttrs (k: v: k != host) (import ../data/keys.nix));
  };
}
