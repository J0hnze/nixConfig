#!/usr/bin/env bash
set -e

FLAKE_PATH="/etc/nixos"
HOSTNAME=$(hostname)

echo "[+] Updating flake inputs..."
sudo nix flake update "$FLAKE_PATH"

echo "[+] Rebuilding system from flake..."
sudo nixos-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"

echo "[+] Done."