#!/usr/bin/env bash

# Get hostname
HOSTNAME=$(hostname)

# Define repo-relative tmp directory
TMP_DIR="./tmp"

# Create tmp directory if it doesn't exist
mkdir -p "$TMP_DIR"

# Output file = hostname
OUTPUT_FILE="$TMP_DIR/${HOSTNAME}.txt"

echo "[+] Saving debug info to: $OUTPUT_FILE"

# Ensure tmp/ is ignored by git
if [ -f ".gitignore" ]; then
    if ! grep -q "^tmp/$" .gitignore; then
        echo "tmp/" >> .gitignore
        echo "[+] Added tmp/ to .gitignore"
    fi
else
    echo "tmp/" > .gitignore
    echo "[+] Created .gitignore and added tmp/"
fi

{
echo "=============================="
echo "  BASIC SYSTEM INFO"
echo "=============================="
hostname
uname -a
echo
cat /etc/os-release 2>/dev/null

echo
echo "=============================="
echo " GPU / VIDEO INFO"
echo "=============================="
lspci | grep -i -E "vga|3d|display"

echo
echo "=============================="
echo " LOADED KERNEL MODULES"
echo "=============================="
lsmod | grep -i -E "vmware|svga|drm"

echo
echo "=============================="
echo "  XRANDR OUTPUT"
echo "=============================="
xrandr || echo "xrandr not available"

echo
echo "=============================="
echo " WAYLAND / X11 SESSION"
echo "=============================="
echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
echo "DESKTOP_SESSION=$DESKTOP_SESSION"

echo
echo "=============================="
echo "  NIXOS CONFIG (VIDEO + VMWARE)"
echo "=============================="
grep -R -E "vmware|videoDrivers|displayManager|desktopManager" /etc/nixos 2>/dev/null

echo
echo "=============================="
echo " VMWARE TOOLS STATUS"
echo "=============================="
systemctl status vmtoolsd.service 2>/dev/null || echo "vmtoolsd not found"

echo
echo "=============================="
echo " DMESG (LAST 200 → FILTERED → LAST 20)"
echo "=============================="
dmesg | tail -n 200 | grep -i -E "vmware|svga|drm" | tail -n 20

echo
echo "=============================="
echo " JOURNAL (LAST 200 → FILTERED → LAST 20)"
echo "=============================="
journalctl -b -n 200 | grep -i -E "vmware|drm|display" | tail -n 20

echo
echo "=============================="
echo " OPENGL INFO"
echo "=============================="
glxinfo 2>/dev/null | grep -E "OpenGL vendor|OpenGL renderer" || echo "glxinfo not installed"

echo
echo "=============================="
echo " NIXOS CONFIG FILES"
echo "=============================="
find /etc/nixos -type f -name "*.nix"

} > "$OUTPUT_FILE"

echo "[+] Done. Share this file:"
echo "    $OUTPUT_FILE"
