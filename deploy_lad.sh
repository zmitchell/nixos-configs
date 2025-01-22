#!/usr/bin/env bash
nixos-rebuild switch --flake .#distant-lad --target-host lad --use-remote-sudo --log-format internal-json 2>&1 | nom --json
