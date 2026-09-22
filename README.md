# NixOS configuration

Declarative NixOS + Home Manager configuration for the test VM.

Includes Hyprland, French AZERTY, Firefox, Spotify, Kitty, Waybar,
Rofi, Dunst, Git, Zsh, Neovim, Docker and common DevOps tools.

Target: `x86_64-linux`, QEMU/KVM, legacy BIOS/GRUB.

For an already-installed VM:

```bash
cp /etc/nixos/hardware-configuration.nix hosts/test-vm/
nixos-rebuild switch --flake .#test-vm
```

Do not commit passwords, private keys, API tokens or cloud credentials.
