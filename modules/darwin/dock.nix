{
  flake.modules.darwin.dock =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.dock;
      applists = {
        options = {
          system = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = null;
            description = "The names (not including `.app`) of builtin Applications to pin to the dock.";
            example = [
              "Messages"
              "Calendar"
            ];
          };
          user = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = null;
            description = "The names (not including `.app`) of user-installed Applications to pin to the dock.";
            example = [
              "Signal"
              "Firefox"
            ];
          };
        };
      };
      mkPaths = (
        lists:
        (lib.map (name: "/System/Applications/${name}.app") cfg.apps.system)
        ++ (lib.map (name: "/Applications/${name}.app") cfg.apps.user)
      );
    in
    {
      options.dock.apps = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule applists);
        default = null;
        description = "The apps to pin to the dock.";
      };

      config = {
        system.defaults.dock = {
          autohide = true;
          mru-spaces = false;
          orientation = "left";
          persistent-apps = if cfg.apps == null then null else mkPaths cfg.apps;
        };
      };
    };
}
