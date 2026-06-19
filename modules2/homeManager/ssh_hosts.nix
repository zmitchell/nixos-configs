{
  flake.modules.homeManager.ssh_hosts =
    {
      config,
      lib,
      osConfig,
      ...
    }:
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
      options.ssh_hosts.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule block);
        description = "The hosts to predefine on this machine.";
        example = {
          chungus = {
            host = "chungus-ts";
            hostname = "chungus";
          };
        };
      };

      config.programs.ssh = {
        enable = true;
        matchBlocks = (lib.mapAttrs (_: opts: {
          inherit (opts) host hostname;
          forwardAgent = true;
          user = osConfig.user_profile.username;
          serverAliveInterval = 60;
          serverAliveCountMax = 10080;
          setEnv.TERM = "xterm-256color";
        }) cfg.hosts) // {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
        };
        enableDefaultConfig = false;

      };
    };
}
