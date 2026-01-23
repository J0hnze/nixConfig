{
  description = "Pentesting Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable-pkgs.url  = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { 
        allowUnfree = true;
      };
    };
      unstable-pkgs = import <nixos-unstable> { 
      config = { 
        allowUnfree = true; 
        }; 
    };
  in
  {
    nixosConfigurations.default= nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/default/configuration.nix
        inputs.home-manager.nixosModules.default
        ./modules
      ];
    };
  };
}
