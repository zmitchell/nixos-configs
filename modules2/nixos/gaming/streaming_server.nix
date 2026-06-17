{
  flake.modules.nixos.game_streaming_server =
    { pkgs, ... }:
    {
      services.sunshine = {
        enable = true;
        openFirewall = true;
        capSysAdmin = true;
        # Enable nvenc support
        package = pkgs.withCudaSupport.sunshine;
      };
    };
}
