#!/usr/bin/env bash

set -e

echo "======================================="
echo "      Advanced NixOS Host Generator"
echo "======================================="
echo

read -rp "Hostname: " HOSTNAME
read -rp "Username: " USERNAME

ARCH=$(uname -m)

case "$ARCH" in
  x86_64) SYSTEM="x86_64-linux" ;;
  aarch64) SYSTEM="aarch64-linux" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Detect EFI vs BIOS
if [ -d /sys/firmware/efi ]; then
  BOOT_MODE="efi"
else
  BOOT_MODE="bios"
fi

# Detect Apple hardware
if grep -qi apple /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null; then
  IS_APPLE="yes"
else
  IS_APPLE="no"
fi

# Ask VM
read -rp "Is this a VM? (y/N): " IS_VM

# Desktop selection
echo
echo "Select Desktop Profile:"
echo "1) Hyprland (Wayland)"
echo "2) Cinnamon"
echo "3) Plasma"
echo "4) Minimal (no desktop)"
echo

read -rp "Choice [1-4]: " DESKTOP_CHOICE

case "$DESKTOP_CHOICE" in
  1) DESKTOP="hyprland" ;;
  2) DESKTOP="cinnamon" ;;
  3) DESKTOP="plasma" ;;
  4) DESKTOP="minimal" ;;
  *) echo "Invalid selection"; exit 1 ;;
esac

HOST_DIR="hosts/$HOSTNAME"

if [ -d "$HOST_DIR" ]; then
  echo "Host directory already exists!"
  exit 1
fi

echo
echo "Creating host directory..."
mkdir -p "$HOST_DIR"

# ------------------------
# custom.nix
# ------------------------

cat > "$HOST_DIR/custom.nix" <<EOF
{
  system = "$SYSTEM";
  username = "$USERNAME";
  desktop = "$DESKTOP";
}
EOF

# ------------------------
# configuration.nix
# ------------------------

cat > "$HOST_DIR/configuration.nix" <<EOF
{ config, pkgs, custom, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "$HOSTNAME";

EOF

# Bootloader config
if [ "$BOOT_MODE" = "efi" ]; then
cat >> "$HOST_DIR/configuration.nix" <<EOF
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

EOF
else
cat >> "$HOST_DIR/configuration.nix" <<EOF
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

EOF
fi

# Apple keyboard defaults
if [ "$IS_APPLE" = "yes" ]; then
cat >> "$HOST_DIR/configuration.nix" <<EOF
  console.keyMap = "uk";

  services.xserver.xkb = {
    layout = "gb";
    variant = "mac";
  };

EOF
fi

# Desktop logic
case "$DESKTOP" in
  hyprland)
cat >> "$HOST_DIR/configuration.nix" <<EOF
  programs.hyprland.enable = true;
  services.xserver.enable = false;

EOF
;;
  cinnamon)
cat >> "$HOST_DIR/configuration.nix" <<EOF
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

EOF
;;
  plasma)
cat >> "$HOST_DIR/configuration.nix" <<EOF
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

EOF
;;
  minimal)
cat >> "$HOST_DIR/configuration.nix" <<EOF
  services.xserver.enable = false;

EOF
;;
esac

# VM support
if [[ "$IS_VM" =~ ^[Yy]$ ]]; then
cat >> "$HOST_DIR/configuration.nix" <<EOF
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];

EOF
fi

# User block
cat >> "$HOST_DIR/configuration.nix" <<EOF
  users.users.\${custom.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}
EOF

# ------------------------
# home.nix
# ------------------------

cat > "$HOST_DIR/home.nix" <<EOF
{ config, pkgs, custom, ... }:

{
  home.username = custom.username;
  home.homeDirectory = "/home/\${custom.username}";
  home.stateVersion = "25.11";
}
EOF

# ------------------------
# Copy hardware config
# ------------------------

if [ -f /etc/nixos/hardware-configuration.nix ]; then
  cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/"
  echo "Hardware configuration copied."
else
  echo "WARNING: hardware-configuration.nix not found."
fi

echo
echo "Host $HOSTNAME created successfully."
echo
echo "Build using:"
echo "sudo nixos-rebuild switch --flake .#$HOSTNAME"
echo

read -rp "Set system hostname now? (y/N): " SET_HOST
if [[ "$SET_HOST" =~ ^[Yy]$ ]]; then
  sudo hostnamectl set-hostname "$HOSTNAME"
  echo "Hostname updated."
fi

echo
echo "Done."