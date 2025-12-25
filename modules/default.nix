{...}:
{
  imports = [
    ./base_system.nix
    ./base_user.nix
    ./modern_boot.nix
    ./generic_desktop.nix
    ./generic_server.nix
    ./gnome.nix
    ./kde.nix
    ./hyprland.nix
    ./game_streaming_client.nix
    ./media_server.nix
    ./flox.nix
    ./static_ip.nix
    ./authorized_keys.nix
    ./styles.nix
    ./add_to_registry.nix
    ./hyprland.nix
    ./nix_community_cachix.nix
    ./games
    ./libvirt_qemu.nix

    # Services
    ./reverse_proxy_with_auth.nix
    ./calibre.nix
    ./mealie.nix
    ./monitoring.nix
  ];
}
