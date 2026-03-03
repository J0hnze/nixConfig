{
  description = "Pentesting Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    mkHost = hostName:
      let
        custom = import ./hosts/${hostName}/custom.nix;
        system = custom.system;

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in
      nixpkgs.lib.nixosSystem {
        inherit system pkgs;

        specialArgs = {
          inherit custom pkgs-unstable;
        };

        modules = [
          ./hosts/${hostName}/configuration.nix
          ./hosts/${hostName}/hardware-configuration.nix
          #./hosts/${hostName}/custom.nix
          ./hosts/common/base.nix
          ./modules/nixos/desktop.nix  
	  ./modules
        ];
      };

    hostDirs =
      builtins.filter
        (name:
          builtins.pathExists ./hosts/${name}/custom.nix
        )
        (builtins.attrNames (builtins.readDir ./hosts));

  in
  {
    nixosConfigurations =
      builtins.listToAttrs
        (map
          (host: {
            name = host;
            value = mkHost host;
          })
          hostDirs);
  };
}
