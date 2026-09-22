{
  description = "Mael's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
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
        ];
      };
    };
}
