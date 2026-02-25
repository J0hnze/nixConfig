{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker.enable = true;

  # Allow your user to run docker without sudo
  users.users.johnze.extraGroups = [ "docker" ];

  # Create persistent storage directory for Nessus
  systemd.tmpfiles.rules = [
    "d /home/johnze/Services/Nessus 0755 johnze users - -"
  ];

  # Open Nessus port
  networking.firewall.allowedTCPPorts = [ 8834 ];

  # Run Nessus container declaratively
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      nessus = {
        image = "tenable/nessus:latest-ubuntu";
        autoStart = true;

        ports = [
          "8834:8834"
        ];

        volumes = [
          "/home/johnze/data/nessus:/opt/nessus" 
        ];

        environment = {
          ACCEPT_EULA = "yes";
        };
      };
    };
  };
}