{ pkgs, lib, config, ...}:
let
  cfg = config.games.streaming_server;
in
{
  options.games.streaming_server = {
    enable = lib.mkEnableOption "Enable a game streaming server";
  };

  config = lib.mkIf cfg.enable {
    # Sunshine game streaming server
    services.sunshine = {
      enable = true;
      openFirewall = true;
      capSysAdmin = true;
      # Enable nvenc support
      package = pkgs.unstable.sunshine;
      # package = with pkgs;
      #   (pkgs.unstable.sunshine.override {
      #     cudaSupport = true;
      #     cudaPackages = cudaPackages;
      #   });
    };
  };
}
