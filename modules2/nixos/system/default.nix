{...}: {
  imports = [
    ./nixos_base.nix
    ./desktop.nix
    ./fish_default_shell.nix
    ./nixpkgs_extras.nix
    ./server.nix
    ./static_ip.nix
    ./styles.nix
    ./systemd_boot_config.nix
  ];
}
