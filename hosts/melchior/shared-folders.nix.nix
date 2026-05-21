{ config, pkgs, username... }:

{
  fileSystems."/home/${username}/pentest" = {
    device = ".host:/pentest";
    fsType = "fuse.vmhgfs-fuse";
    options = [
      "allow_other"
      "uid=${toString config.users.users.${username}.uid}"
      "x-systemd.automount"
      "noatime"
    ];
  };

  services.open-vm-tools.enable = true;
}