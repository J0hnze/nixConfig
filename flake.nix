{
  description = "Pentesting Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    # 🔑 Define your hosts here
    hosts = [
      "melchior"
      # "shinji"
      # "asuka"
      # "penpen"
    ];

  in {
    nixosConfigurations =
      builtins.listToAttrs (map (hostName: {
        name = hostName;
        value =
          let
            custom = import ./hosts/${hostName}/custom.nix;
            system = custom.system;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          in
          nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit pkgs-unstable hostName;
            inherit custom;
          };

          modules = [
            ./hosts/${hostName}/configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
            #./hosts/${hostName}/shared-folders.nix

            ./hosts/common/base.nix
            ./modules
          ];
        };
      }) hosts);
  };
}
