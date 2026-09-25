{ pkgs, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/mael/nixos-config";
  };

  programs.nix-index-database.comma.enable = true;

  # The toolchains and editors are mael's, so they live in Home Manager.
  # Only the two fetchers stay system-wide: NixOS puts neither on the path by
  # default (environment.defaultPackages is perl, rsync and strace), and root
  # shells and scripts expect them to exist.
  environment.systemPackages = with pkgs; [
    curl
    wget
  ];

  # A loader for prebuilt binaries that expect a normal FHS layout. VS Code
  # extensions, language servers and toolchain installers routinely download
  # such binaries, and they cannot run on NixOS without it.
  programs.nix-ld.enable = true;

  # Rootless: the daemon runs as the desktop user inside a user namespace, so
  # nobody needs the "docker" group. That group is root on the host - the
  # socket happily starts a container that bind mounts / - which would undo
  # security.sudo.wheelNeedsPassword. setSocketVariable points DOCKER_HOST at
  # the per-user socket, and the module installs the matching docker CLI;
  # listing pkgs.docker as well would risk a client/daemon version split.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # minikube runs on podman rather than on the docker daemon above, because
  # rootless docker 29 cannot copy a file into a container that has any
  # read-only bind mount: the daemon re-mounts the container filesystem to
  # write the file and the read-only remount is refused inside its user
  # namespace ("remount-ro ..., flags: 0x1021: operation not permitted").
  # minikube always mounts the host kernel modules read-only, so it fails
  # while installing the SSH key it provisions the node with. podman is
  # daemonless and copies the file from the caller's own namespace, where the
  # same mount is allowed. Both stacks coexist; only the CLI differs.
  virtualisation.podman.enable = true;

  # A rootless daemon only gets the cgroup controllers systemd delegates to
  # the user slice, and cpu and cpuset are not among the defaults. The kubelet
  # minikube runs inside its container needs them to apply CPU limits, so it
  # refuses to start without this.
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
    serviceConfig.Delegate = "cpu cpuset io memory pids";
  };

  # Installs git system-wide.
  programs.git.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
