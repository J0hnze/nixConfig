{ config, lib, ... }:

{
  imports = [
    ./kde.nix
  ];

  config = {
    my.display.kde.enable = lib.mkDefault true;
  };
}