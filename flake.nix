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

    # Presence daemon, enabled in ./home/os-tracker.nix.
    os-tracker = {
      url = "github:mael-app/os-tracker";
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

      # Shared by the session and the login screen, so changing the image is
      # a one line edit here.
      wallpaper = ./home/wallpapers/Liquid.png;

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
              wallpaper
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
            ./modules/greeter.nix
            ./modules/user.nix
            ./modules/vpn.nix

            nix-index-database.nixosModules.nix-index
          ]
          ++ extraModules;
        };
    in
    {
      # Each name is the machine's hostname, which is what nixos-rebuild and
      # nh select by default, so neither needs to be told which host to build.
      # modules/common.nix sets networking.hostName from the same string.

      # QEMU/KVM test VM (virt-manager)
      nixosConfigurations.nixos-test = mkHost "nixos-test" [ ];

      # External USB SSD, booted on the laptop
      nixosConfigurations.nixos-usb = mkHost "nixos-usb" [
        ./modules/laptop.nix
        ./modules/gaming.nix
      ];

      # Laptop internal NVMe
      nixosConfigurations.nixos-laptop = mkHost "nixos-laptop" [
        ./modules/laptop.nix
        ./modules/gaming.nix
      ];

      # nixfmt-tree wraps nixfmt in treefmt, so `nix fmt` formats the whole
      # repository and `nix fmt -- --ci` checks it without rewriting anything.
      # Calling nixfmt directly only accepts individual files.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
