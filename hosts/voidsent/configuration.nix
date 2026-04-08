{ config, pkgs, custom, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "voidesnt";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  services.xserver.videoDrivers = [ "vmware" ];

  users.users.${custom.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}