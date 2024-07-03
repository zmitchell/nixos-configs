{ config, pkgs, ... }:
{
  environment.systemPackages = [
    # (pkgs.runCommandCC "disko-scripts" {} ''
    #   mkdir -p $out/bin
    #   ln -s ${config.system.build.diskoScript} $out/bin/disko-script
    #   ln -s ${config.system.build.formatScript} $out/bin/disko-format
    #   ln -s ${config.system.build.mountScript} $out/bin/mount-script
    #   '')
     config.system.build.diskoScript
     config.system.build.formatScript
     config.system.build.mountScript
  ];
}
