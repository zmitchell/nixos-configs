{writeShellApplication, nixos-rebuild}:
let
  remoteHosts = [ "chungus" "smolboi" ];
  cmdTemplate = { cmd, host }: "nixos-rebuild ${cmd} --flake .#${host} --fast --build-host ${host}-ts --target-host ${host}-ts --use-substitutes --use-remote-sudo";
  checkCmd = host: cmdTemplate { cmd = "build"; host = host; };
  switchCmd = host: cmdTemplate { cmd = "switch"; host = host; };
  checkCmds = builtins.concatStringsSep "\n" (builtins.map checkCmd remoteHosts);
  switchCmds = builtins.concatStringsSep "\n" (builtins.map switchCmd remoteHosts);
in
writeShellApplication {
  name = "deploy-config";
  runtimeInputs = [ nixos-rebuild ];
  text = ''
    darwin-rebuild build --flake .#chonker
    ${checkCmds}
    darwin-rebuild switch --flake .#chonker
    ${switchCmds}
  '';
} 
