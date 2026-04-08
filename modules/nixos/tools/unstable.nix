{ pkgs-unstable }:
{
  lib,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs-unstable; [
    #android-studio  -- doesnt work with aarch64-linux
    bruno
    (burpsuite.override { proEdition = true; })
    jsubfinder
    massdns
    netexec
    nixfmt
    nuclei
    platformio
    postman
    shuffledns
    subfinder
    vscode
  ];
}
