{ config, pkgs, custom, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  security.rtkit.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 80 443 8000 8080 8083 27042 3128 5930
    ];
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = false;
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;

  programs = {
    firefox.enable = true;
    zsh.enable = true;
    nix-ld.enable = true;
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "25.11";
}