{ pkgs-unstable }:
{
  imports = [
    ./nixos/tester.nix
    ./nixos/tools/docker.nix
    ./nixos/tools/stable.nix
    ((import ./nixos/tools/unstable.nix) { inherit pkgs-unstable; })
  ];
}
