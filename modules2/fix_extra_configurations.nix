{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in {
  options.flake = mkSubmoduleOptions {
    darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
    homeConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
    };
  };
}
