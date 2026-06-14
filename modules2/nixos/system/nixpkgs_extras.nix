{config, lib, inputs, ...}:
let
  cfg = config.nixpkgs_extras;
in
{
  options.nixpkgs_extras = {
    unstable = {
      enable = lib.mkEnableOption "Add an 'unstable' package set to Nixpkgs";
    };
    cuda = {
      enable = lib.mkEnableOption "Add CUDA-enabled packages to Nixpkgs";
    };
    registry-release = {
      enable = lib.mkEnableOption "Add a 'release' name to the flake registry";
    };
    community_cachix = {
      enable = lib.mkEnableOption "Enable the nix-community Cachix";
    };
  };

  config = {
    nixpkgs.allowUnfree = true;

    nixpkgs.overlays = [
      (lib.optional cfg.unstable.enable
        (final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (final) system;
            config.allowUnfree = true;
          };
        }))
      (lib.optional cfg.cuda.enable
        (final: _prev: {
          withCudaSupport = import inputs.nixpkgs-unstable {
            inherit (final) system;
            config.cudaSupport = true;
            config.allowUnfree = true;
          };
        }))
    ];

    nix.registry = lib.mkIf cfg.registry-release {
      release.flake = inputs.nixpkgs;
    };

    nix.settings = lib.mkIf cfg.community_cachix {
      substituters = lib.mkAfter [ "https://nix-community.cachix.org" ];
      trusted-public-keys = lib.mkAfter [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
  };
}
