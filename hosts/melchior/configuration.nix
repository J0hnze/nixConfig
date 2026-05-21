{ config, pkgs, custom, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/display/display-main.nix
  ];

  networking.hostName = "melchior";

  # ─────────────────────────────
  # Bootloader
  # ─────────────────────────────
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  #  Enable X server properly
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "vmware" ];

  #  VMware guest support
  virtualisation.vmware.guest.enable = true;

  #  Desktop environment (you were missing this)
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = false; # important
  services.xserver.desktopManager.plasma6.enable = true;

  #  This is the KEY for dual monitors
  services.xserver.deviceSection = ''
    Option "DynamicResize" "true"
  '';

  hardware.graphics.enable = true;

  users.users.${custom.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };
}