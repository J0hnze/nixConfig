{ config, pkgs, custom, ... }:

{
  networking.hostName = "shinji";

  # Keyboard layout (console)
  console.keyMap = "uk";

  # X11 / Wayland keyboard layout
  services.xserver = {
    xkb.layout = "gb";
    xkb.variant = "";
  };

  users.users.${custom.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  imports = [
    ./hardware-configuration.nix
  ];
}