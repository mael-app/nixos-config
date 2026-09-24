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
      nix-index-database,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "mael";

      # Modules shared by every machine. Each host adds its own
      # configuration.nix and hardware-configuration.nix, plus whatever
      # hardware modules it needs.
      #
      # The platform comes from nixpkgs.hostPlatform in each
      # hardware-configuration.nix, so nixosSystem is not given a `system`.
      mkHost =
        host: extraModules:
        nixpkgs.lib.nixosSystem {
          # Reaches every module, including the Home Manager ones, which
          # ./modules/user.nix forwards them to. Nothing has to name the host
          # or the account again.
          specialArgs = {
            inherit
              inputs
              self
              host
              username
              ;
          };

          modules = [
            ./hosts/${host}/configuration.nix
            ./hosts/${host}/hardware-configuration.nix
            ./modules/audio.nix
            ./modules/bluetooth.nix
            ./modules/common.nix
            ./modules/desktop.nix
            ./modules/devops.nix
            ./modules/fonts.nix
            ./modules/user.nix
            ./modules/vpn.nix

            nix-index-database.nixosModules.nix-index
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
