{callPackage, symlinkJoin, writeShellScriptBin, ...}:
let
  common = callPackage ./common.nix;
  soft-reboot = writeShellScriptBin "soft-reboot" ''
    systemctl soft-reboot
  '';
  boot-windows = writeShellScriptBin "boot-windows" ''
    systemctl reboot --boot-loader-entry=auto-windows
  '';
  boot-uefi = writeShellScriptBin "boot-uefi" ''
    systemctl reboot --firmware-setup
  '';
in symlinkJoin {
  name = "boot-helpers";
  paths = [
    soft-reboot
    boot-windows
    boot-uefi
  ];
}
