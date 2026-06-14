{config, lib, user, ...}:
let
  cfg = config.ssh_hosts;
  block.options = {
    host = lib.mkOption {
      type = lib.types.str;
      description = "The name you'll use to connect with the machine.";
      example = "chungus-ts";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "The actual hostname of the machine (e.g. IP address or Tailscale hostname).";
      example = "192.168.8.123";
    };
  };
in
{
  options.ssh_hosts = {
    enable = lib.mkEnableOption "Predefine a set of SSH hosts.";
    hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule block);
      description = "The hosts to predefine on this machine.";
      example = { host = "chungus-ts"; hostname = "chungus"; };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.matchBlocks =
      lib.attrsets.mapAttrs
      (name: opts: {
        host = opts.host;
        hostname = opts.hostname;
        forwardAgent = true;
        user = user.username;
        serverAliveInterval = 60;
        serverAliveCountMax = 10080; # one week max
        setEnv = {
          # Fix for ghostty
          TERM = "xterm-256color";
        };
      })
      cfg.hosts;
  };
}
