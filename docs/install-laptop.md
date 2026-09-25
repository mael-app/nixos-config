# Replace Pop!_OS with NixOS on the internal disk

The installation runs **from the NixOS USB drive**, which already contains
everything needed. If something goes wrong, the drive remains a complete
rescue system.

Windows is not touched: it is on the other disk (`nvme1n1`), and the script
refuses any disk containing a BitLocker volume.

## Internal disk layout (`nvme0n1`, 954 GB)

| Partition | Size | Contents |
| --- | --- | --- |
| `LAPBOOT` | 1 GiB | FAT32, boot (systemd-boot) |
| `LAPCRYPT` | 199 GiB | LUKS2 -> btrfs `nixos-sys`: subvolumes `@` (root) and `@nix` |
| `LAPHOME` | remainder (~754 GB) | LUKS2 -> btrfs `nixos-home`: subvolume `@home` |

`/home` is on its **own encrypted volume**: you can reinstall the system
without touching your data. Both volumes use the same passphrase, and systemd
caches it during boot: you only type it once.

To change the system size:
`SYS_SIZE=300GiB bash scripts/install-laptop.sh`

## 0. Before you start

- [ ] **Back up Pop!_OS**: the disk is erased completely. Push your Git
      repositories, copy everything else to an external disk, and do not
      forget your SSH/GPG keys and configuration files.
- [ ] BitLocker recovery key recorded (as a precaution).

## 1. Installer

Boot from the USB drive, connect to Wi-Fi, then:

```sh
git clone https://github.com/mael-app/nixos-config ~/nixos-config
cd ~/nixos-config
nix shell nixpkgs#parted nixpkgs#cryptsetup nixpkgs#dosfstools \
      nixpkgs#btrfs-progs nixpkgs#util-linux \
      -c bash scripts/install-laptop.sh
```

The `nix shell` command provides the partitioning, encryption, and formatting
tools needed in the USB drive's live environment.

The script checks the disk, asks you to type `ERASE`, then performs
partitioning, encryption, formatting, installation, the `mael` password, and
unmounting.

## 2. First boot

Reboot and **remove the drive**. NixOS boots from the internal disk and this
time registers itself in the BIOS (`canTouchEfiVariables = true`).

Enter the passphrase, then log in.

## 3. Automatic TPM unlocking

To stop entering the passphrase at every boot:

```sh
cd ~/nixos-config
bash scripts/enroll-tpm.sh
```

The laptop's TPM then unlocks both volumes. The passphrase remains available:
if the TPM refuses (updated BIOS, changed Secure Boot, or the disk moved to
another machine), it is requested again.

## 4. Cleanup

The old "Pop!_OS" boot entry remains in the BIOS with nothing behind it:

```sh
sudo efibootmgr              # find the Pop!_OS entry number
sudo efibootmgr -b <n> -B    # remove the entry
```

Windows remains available from the BIOS boot menu.

## Updates

```sh
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos-laptop
```

## Troubleshooting

| Problem | Solution |
| --- | --- |
| "the disk contains the running system" | The script targets `/dev/nvme0n1` by default; check with `lsblk` and override with `TARGET=...` |
| The system does not boot after installation | Boot from the USB drive, mount the volumes again, and rerun `bash scripts/install-laptop.sh --install-only` |
| The passphrase is requested twice | systemd caching did not work: check that `boot.initrd.systemd.enable` is enabled |
| The TPM requests the passphrase again | Secure Boot or BIOS state changed: rerun `scripts/enroll-tpm.sh` |
