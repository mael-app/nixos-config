# Install NixOS on the USB SSD (from Pop!_OS)

The installation runs **from Pop!_OS**, which already has Nix: no installer
drive is needed, the VPN and Internet work as usual, and you can read this
guide during the installation.

Result: a drive containing everything (boot files and encrypted system) that
boots from the BIOS boot menu. The internal disks (Pop!_OS and Windows) and
the PC's boot entries are not modified.

> **Shortcut**: `bash scripts/install-usb.sh` performs steps 1 through 7
> automatically (with confirmations). The details below explain what it does,
> or let you perform it manually.

Drive layout (already described in `hosts/usb/hardware-configuration.nix`):

| Partition | Taille | Contenu |
| --- | --- | --- |
| `NIXBOOT` | 1 GiB | FAT32, boot partition (systemd-boot) |
| `NIXCRYPT` | remainder | Encrypted LUKS2 containing a compressed (zstd) `nixos` btrfs with subvolumes `@`, `@home`, `@nix` |

---

## 0. Avant de commencer

- [ ] **Back up the drive's contents**: it will be erased completely.
- [ ] **Record your BitLocker recovery key** (Windows): disabling Secure Boot
   may make Windows request it at the next boot. It is available at
   <https://account.microsoft.com/devices/recoverykey>, or in Windows:
   `manage-bde -protectors -get C:`.
- [ ] Find your PC's **boot menu key** (often F12, F8, F9, or Esc depending on
   the manufacturer).
- [ ] In China: connect Mullvad on Pop!_OS before step 5 (GitHub and the Nix
   cache are slow or blocked without a VPN).

Required tools on Pop!_OS:

```sh
sudo apt install btrfs-progs parted cryptsetup dosfstools
```

## 1. Identify the drive

```sh
lsblk -dno NAME,TRAN,SIZE,MODEL
```

Find the line `usb  ...  SSK Portable SSD 128GB` (for example `sda`), then:

```sh
DISK=/dev/sda   # ⚠️ replace this with YOUR drive name
lsblk "$DISK"   # check: ~119G, not nvme0n1 or nvme1n1
```

> ⚠️ **Check three times.** `nvme0n1` = Pop!_OS, `nvme1n1` = Windows. Choosing
> the wrong disk will erase it.

## 2. Partition

```sh
# Unmount the drive if Pop!_OS mounted it automatically
sudo umount "$DISK"?* 2>/dev/null

sudo wipefs -a "$DISK"
sudo parted -s "$DISK" -- \
  mklabel gpt \
  mkpart NIXBOOT fat32 1MiB 1GiB \
  set 1 esp on \
  mkpart NIXCRYPT 1GiB 100%

lsblk "$DISK"   # should show ${DISK}1 (1G) and ${DISK}2 (~118G)
```

## 3. Format and encrypt

```sh
sudo mkfs.fat -F 32 -n NIXBOOT "${DISK}1"

# Choose a passphrase: it will be requested at every boot
sudo cryptsetup luksFormat --type luks2 --label NIXCRYPT "${DISK}2"
sudo cryptsetup open "${DISK}2" cryptroot

sudo mkfs.btrfs -L nixos /dev/mapper/cryptroot
```

## 4. Create subvolumes and mount

```sh
sudo mount /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@ /mnt/@home /mnt/@nix
sudo umount /mnt

sudo mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/home /mnt/nix /mnt/boot
sudo mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
sudo mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
sudo mount -o fmask=0077,dmask=0077 "${DISK}1" /mnt/boot

findmnt -R -l /mnt   # 4 mount points: /mnt, /mnt/home, /mnt/nix, /mnt/boot
```

## 5. Installer

```sh
cd ~/Developer/nixos-config
git pull

# NixOS installation tools, matching the configuration version
nix shell .#nixosConfigurations.usb.pkgs.nixos-install-tools

# In this shell:
sudo env "PATH=$PATH" nixos-install --root /mnt --flake .#usb --no-root-passwd
```

This downloads the entire system (several GB): allow 10 to 40 minutes.

> **Without a VPN / if it is very slow**: add the Chinese Nix cache mirrors
> (with the same signature as the official cache) to the command:
>
> ```sh
> sudo env "PATH=$PATH" nixos-install --root /mnt --flake .#usb --no-root-passwd \
>   --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10 https://mirrors.ustc.edu.cn/nix-channels/store?priority=20 https://cache.nixos.org"
> ```
>
> `priority` puts the mirrors before the official cache. Chinese mirrors often
> refuse connections from a VPN: disconnect Mullvad to use them.

## 6. User password

The `mael` user does not have a password yet (required to log in, use `sudo`,
and unlock the screen):

```sh
sudo env "PATH=$PATH" nixos-enter --root /mnt -c '/nix/var/nix/profiles/system/sw/bin/passwd mael'
```

Then exit the `nix shell` (`exit`).

## 7. Unmount cleanly

```sh
sudo umount -R /mnt
sudo cryptsetup close cryptroot
```

## 8. Boot from the drive

1. Reboot and enter the BIOS: **disable Secure Boot** (and check that USB
   boot is allowed).
2. Reboot, press the **boot menu key**, and choose the drive (SSK / UEFI USB).
3. systemd-boot -> NixOS -> **LUKS passphrase** -> login screen (greetd) ->
   Hyprland.

Without the drive connected, the PC boots into Pop!_OS as before.

## 9. After the first boot

Clone the repository to perform updates:

```sh
git clone https://github.com/mael-app/nixos-config ~/nixos-config
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#usb
```

The display scale is set in `hosts/usb/configuration.nix` (`scale = 1.25`).
Valid values for 2560x1600: `1`, `1.0667`, `1.25`, `1.3333`, `1.6`, `2`.

## Troubleshooting

| Problem | Solution |
| --- | --- |
| The drive does not appear in the boot menu | Secure Boot is still enabled, or USB boot is disabled in the BIOS |
| Windows requests the BitLocker key | Normal after changing Secure Boot: enter the recovery key |
| "waiting for device /dev/disk/by-label/NIXCRYPT" | Connect the drive directly to a USB port on the PC (not through a hub) |
| Wi-Fi is unavailable | Use `nmtui` to connect, or use the network icon in the bar |
| Disk space is full | `sudo nix-collect-garbage -d` (automatic cleanup already runs weekly) |

Never disconnect the drive while NixOS is running.
