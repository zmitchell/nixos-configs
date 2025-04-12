#!/usr/bin/env

sudo nix run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake .#slim --disk main /dev/nvme0n1
