{
  description = "Pentesting Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    hosts = [
      #"melchior"
       "shinji"
      # "asuka"
      # "rei"
    ];

    mkHost = hostName:
      let
        custom = import ./hosts/${hostName}/custom.nix;
        system = custom.system;

        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        name = hostName;

        value = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs custom hostName pkgs-unstable;
          };

          modules = [
            ./hosts/${hostName}/configuration.nix
            ./hosts/common/base.nix

            # Only keep this if ./modules/default.nix exists
            ./modules
          ];
        };
      };

  in {
    nixosConfigurations =
      builtins.listToAttrs (map mkHost hosts);
  };
}