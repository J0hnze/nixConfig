{ ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.nessus = {
      image = "tenable/nessus:latest-ubuntu";

      ports = [
        "8834:8834"
      ];

      volumes = [
        "nessus_data:/opt/nessus/var/nessus"
      ];

      autoStart = true;
    };
  };
}
