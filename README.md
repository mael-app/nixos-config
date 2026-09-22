# NixOS configuration

## Current target

`test-vm` — x86_64 NixOS VM running Hyprland.

## What is included

- Hyprland + XWayland
- greetd + tuigreet
- Firefox
- Spotify
- Kitty
- Waybar
- Rofi
- Dunst
- PipeWire
- NetworkManager
- Git
- Zsh
- Neovim
- tmux
- Docker
- kubectl
- Helm
- Terraform
- Ansible
- Python
- Node.js
- Go

## Installation

From the NixOS live ISO:

1. Partition and mount the VM disk.
2. Generate hardware configuration:

   `nixos-generate-config --root /mnt`

3. Copy the generated file into this repo:

   `cp /mnt/etc/nixos/hardware-configuration.nix /path/to/nixos-config/hosts/test-vm/`

4. Build/install:

   `nixos-install --flake /path/to/nixos-config#test-vm`

5. Reboot.

6. Set Maël's password:

   `passwd mael`

## After boot

Update the system with:

`sudo nixos-rebuild switch --flake ~/nixos-config#test-vm`

## Important

Never commit:

- passwords
- SSH private keys
- API tokens
- cloud credentials
- `.env` files containing secrets

For secrets, use a tool such as sops-nix later.
