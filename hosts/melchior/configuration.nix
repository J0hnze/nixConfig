{ config, pkgs, custom, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "melchior";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  services.xserver.videoDrivers = [ "vmware" ];
  virtualisation.vmware.guest.enable = true;
  hardware.graphics.enable = true;
 
  users.users.${custom.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}