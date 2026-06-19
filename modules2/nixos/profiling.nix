{
  flake.modules.nixos.profiling =
    {
      pkgs,
      ...
    }:
    {
      boot.kernel.sysctl = {
        "perf_event_paranoid" = 1;
        "perf_event_mlock_kb" = 2048;
      };
      environment.systemPackages = with pkgs; [
        perf
        linuxHeaders
        unstable.bpftrace
      ];
    };
}
