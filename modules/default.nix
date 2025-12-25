{...}:
{
  imports = [
    ./base_system.nix
    ./base_user.nix
    ./modern_boot.nix
    ./generic_desktop.nix
    ./generic_server.nix
    # TODO: this duplicates the `games` folder,
    #       but smolboi is still using this
    ./game_streaming_client.nix
    ./flox.nix
    ./static_ip.nix
    ./authorized_keys.nix
    ./styles.nix
    ./add_to_registry.nix
    ./nix_community_cachix.nix
    ./libvirt_qemu.nix

    # Collections
    ./services
    ./games
    ./desktop_environments
  ];
}
