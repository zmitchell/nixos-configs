{ ... }:
{
  imports = [
    ./calibre.nix
    ./mealie.nix
    ./booklore.nix
    ./monitoring.nix
    ./reverse_proxy_with_auth.nix
  ];
}
