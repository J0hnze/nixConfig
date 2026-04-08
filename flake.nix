{
  description = "Pentesting Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, headplane, ... }@inputs:
  let
    system = "aarch64-linux";
    # system = "x86_64-linux";

    # Stable packages
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Unstable packages
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # 🔑 Define your hosts here
    hosts = [
      "melchior"
      # "shinji"
      # "asuka"
      # "rei"
    ];

<<<<<<< HEAD
  in {
=======
        modules = [
          ./hosts/${hostName}/configuration.nix
          ./hosts/${hostName}/hardware-configuration.nix
          ./hosts/${hostName}/shared-folders.nix
          #./hosts/${hostName}/home.nix
          ./hosts/common/base.nix
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
>>>>>>> 64e543f (.)
    nixosConfigurations =
      builtins.listToAttrs (map (hostName: {
        name = hostName;
        value = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit pkgs-unstable hostName;
          };

          modules = [
            ./hosts/${hostName}/configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix

            ./hosts/common/base.nix
            ./modules
          ];
        };
      }) hosts);
  };
}