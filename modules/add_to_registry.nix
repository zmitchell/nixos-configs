{ inputs, config, lib, ... }:
let
  cfg = config.addStableBranchToRegistry;
in
{
  options.addStableBranchToRegistry = {
    enable = lib.mkEnableOption "Adds the stable branch the system was built against to the registry as 'release'.";
  };
  config = lib.mkIf cfg.enable {
    nix.registry.release.flake = inputs.nixpkgs;
  };
}
