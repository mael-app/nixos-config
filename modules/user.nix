{
  self,
  inputs,
  host,
  username,
  ...
}:

# The account and the Home Manager wiring. `username` and `host` come from
# specialArgs in flake.nix and are forwarded to the Home Manager modules, so
# the account name is written once in the whole repository.
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users.users.${username} = {
    isNormalUser = true;
    description = "Maël";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  # Record the commit a generation was built from, so
  # `nixos-version --configuration-revision` can identify it.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Without this, activation aborts as soon as a file it manages already
    # exists in $HOME instead of moving the old one aside.
    backupFileExtension = "hm-bak";

    extraSpecialArgs = { inherit inputs host username; };

    users.${username} = import ../home;
  };
}
