#!/bin/sh
cat /etc/nixos/hardware-configuration.nix > ./hosts/common/hardware-configuration.nix
echo "hardware-configuration.nix copied!"
