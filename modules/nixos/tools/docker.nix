{ config, pkgs, lib, custom, ... }:

let
  username = custom.username or null;
in {
  imports = [
    ../../../docker-images/nessus.nix
  ];

  # ------------------------------------------------------------
  # Enable Docker
  # ------------------------------------------------------------
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Allow the configured user to run docker without sudo
  users.users = lib.mkIf (username != null) {
    ${username}.extraGroups = [ "docker" ];
  };
} 
