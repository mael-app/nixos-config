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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";

      # Modules shared by every machine. Each host adds its own
      # configuration.nix and hardware-configuration.nix, plus whatever
      # hardware modules it needs.
      #
      # The platform comes from nixpkgs.hostPlatform in each
      # hardware-configuration.nix, so nixosSystem is not given a `system`.
      mkHost =
        host: extraModules:
        nixpkgs.lib.nixosSystem {
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
              # Record the commit a generation was built from, so
              # `nixos-version --configuration-revision` can identify it.
              system.configurationRevision = self.rev or self.dirtyRev or null;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Without this, activation aborts as soon as a file it manages
              # already exists in $HOME instead of moving the old one aside.
              home-manager.backupFileExtension = "hm-bak";
              home-manager.users.mael = import ./home/mael;
            }
          ]
          ++ extraModules;
        };
    in
    {
      # QEMU/KVM test VM (virt-manager)
      nixosConfigurations.test-vm = mkHost "test-vm" [ ];

      # External USB SSD, booted on the laptop
      nixosConfigurations.usb = mkHost "usb" [ ./modules/laptop.nix ];

      # Laptop internal NVMe
      nixosConfigurations.laptop = mkHost "laptop" [ ./modules/laptop.nix ];

      # nixfmt-tree wraps nixfmt in treefmt, so `nix fmt` formats the whole
      # repository and `nix fmt -- --ci` checks it without rewriting anything.
      # Calling nixfmt directly only accepts individual files.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
