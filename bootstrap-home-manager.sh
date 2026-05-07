#!/usr/bin/env bash

set -euo pipefail

host="${1:?}"

nix run --extra-experimental-features "nix-command flakes" --accept-flake-config github:nix-community/home-manager -- switch --flake ".#$host"
