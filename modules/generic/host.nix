{
  flake.modules.generic.host =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.host;
    in
    {
      options.host = lib.mkOption {
        type = lib.types.str;
        description = "The name of the host";
        example = "chonker";
      };

      config = {
        networking.hostName = cfg;
      };
    };
}
