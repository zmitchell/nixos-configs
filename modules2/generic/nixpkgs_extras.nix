{
  inputs,
  ...
}:
{
  flake.modules.generic.nixpkgs_unstable = {
    nixpkgs.overlays = [
      (final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          localSystem = final.stdenv.hostPlatform;
          config.allowUnfree = true;
        };
      })
    ];
  };
  flake.modules.generic.community_cachix =
    {
      lib,
      ...
    }:
    {
      nix.settings = {
        substituters = lib.mkAfter [ "https://nix-community.cachix.org" ];
        trusted-public-keys = lib.mkAfter [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  flake.modules.nixos.cuda_pkgs = {
    nixpkgs.overlays = [
      (final: _prev: {
        withCudaSupport = import inputs.nixpkgs-unstable {
          localSystem = final.stdenv.hostPlatform;
          config.cudaSupport = true;
          config.allowUnfree = true;
        };
      })
    ];
  };
}
