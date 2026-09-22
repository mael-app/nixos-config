{
  description = "Mael's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/test-vm/configuration.nix
          ./hosts/test-vm/hardware-configuration.nix
          ./modules/desktop.nix
          ./modules/devops.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mael = import ./home/mael;
          }
        ];
      };
    };
}
