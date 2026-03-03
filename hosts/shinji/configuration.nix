{ config, pkgs, custom, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "shinji";

  # Correct for EFI / Apple Silicon
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  console.keyMap = "uk";

  services.xserver.xkb = {
    layout = "gb";
    variant = "mac";
  };

  users.users.${custom.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}