#!/usr/bin/env bash

set -euo pipefail

host="${1:?}"

# So we don't have to rebuild the universe when installing Flox
sudo tee -a /etc/nix/nix.conf << 'EOF'
extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=
extra-trusted-substituters = https://cache.flox.dev
trusted-users = root zmitchell
EOF

# The daemon isn't started by default for whatever reason
sudo systemctl enable nix-daemon
sudo systemctl start nix-daemon

# Bootstrap home-manager
# git clone https://github.com/zmitchell/nixos-configs.git git-nix-config
# cd git-nix-config
nix run --extra-experimental-features "nix-command flakes" --accept-flake-config github:nix-community/home-manager -- switch --flake ".#$host" -b bak

echo "Update shell: sudo chsh -s ~/.nix-profile/bin/fish zmitchell"
