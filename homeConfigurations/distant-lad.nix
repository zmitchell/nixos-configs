{pkgs, lib, inputs, user, ...}:
let
  shellAliases = import ./shell-aliases.nix;
  # bpftrace-wrapped = pkgs.runCommand "bpftrace-with-kernel-source" {
  #   # inherit (pkgs.bpftrace) pname version meta outputs postInstall;
  #   # inherit (pkgs.bpftrace) postInstall;
  #   nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
  #   propagatedBuildInputs = [ pkgs.linuxHeaders ];
  # } ''
  #   mkdir $out
  #   cp -rs --no-preserve=mode,ownership ${pkgs.bpftrace.out}/* $out/
  #   rm -rf $out/bin/bpftrace
  #   makeWrapper ${pkgs.bpftrace}/bin/bpftrace $out/bin/bpftrace --set BPFTRACE_KERNEL_SOURCE ${pkgs.linuxHeaders} 
  #   find ${pkgs.bpftrace}/bin -t f -name '*.bt' 
  #   # mkdir $man
  #   # cp -R ${pkgs.bpftrace.man}/* $man/
  # '';
in
{
  imports = [
    ./common.nix
  ];

  home.stateVersion = "24.11";

}

