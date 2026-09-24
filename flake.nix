{
  description = "Mael's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-index-database, ... }:
    let
      system = "x86_64-linux";

      # Modules shared by every machine; each host only adds its own
      # configuration.nix and hardware-configuration.nix.
      mkHost = host: nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/${host}/configuration.nix
          ./hosts/${host}/hardware-configuration.nix
          ./modules/common.nix
          ./modules/desktop.nix
          ./modules/devops.nix
          ./modules/vpn.nix

          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.nix-index
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mael = import ./home/mael;
          }
        ];
      };
    in {
      # QEMU/KVM test VM (virt-manager)
      nixosConfigurations.test-vm = mkHost "test-vm";

      # External USB SSD, booted on the laptop
      nixosConfigurations.usb = mkHost "usb";

      # Laptop internal NVMe
      nixosConfigurations.laptop = mkHost "laptop";
    };
}
