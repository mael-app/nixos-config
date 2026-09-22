# Installer NixOS sur la clé USB SSD (depuis Pop!_OS)

L'installation se fait **depuis Pop!_OS**, qui a déjà Nix : pas besoin de
clé d'installation, le VPN et Internet marchent comme d'habitude, et tu
peux lire ce guide pendant l'installation.

Résultat : une clé qui contient tout (démarrage + système chiffré), qui
démarre depuis le menu de démarrage du BIOS. Les disques internes (Pop!_OS
et Windows) et les entrées de démarrage du PC ne sont pas modifiés.

> **Raccourci** : `bash scripts/install-usb.sh` fait les étapes 1 à 7
> automatiquement (avec confirmations). Le détail ci-dessous explique ce
> qu'il fait, ou permet de le faire à la main.

Disposition de la clé (déjà décrite dans `hosts/usb/hardware-configuration.nix`) :

| Partition | Taille | Contenu |
| --- | --- | --- |
| `NIXBOOT` | 1 Gio | FAT32, partition de démarrage (systemd-boot) |
| `NIXCRYPT` | le reste | LUKS2 chiffré, contenant un btrfs `nixos` compressé (zstd) avec les sous-volumes `@`, `@home`, `@nix` |

---

## 0. Avant de commencer

- [ ] **Sauvegarde le contenu de la clé** : elle va être entièrement effacée.
- [ ] **Note ta clé de récupération BitLocker** (Windows) : désactiver le
      Secure Boot peut la faire demander au prochain démarrage de Windows.
      Elle est sur <https://account.microsoft.com/devices/recoverykey>, ou sous
      Windows : `manage-bde -protectors -get C:`.
- [ ] Repère la **touche du menu de démarrage** de ton PC (souvent F12, F8,
      F9 ou Échap selon la marque).
- [ ] En Chine : connecte Mullvad sur Pop!_OS avant l'étape 5 (GitHub et le
      cache Nix sont lents ou bloqués sans VPN).

Outils nécessaires sur Pop!_OS :

```sh
sudo apt install btrfs-progs parted cryptsetup dosfstools
```

## 1. Identifier la clé

```sh
lsblk -dno NAME,TRAN,SIZE,MODEL
```

Cherche la ligne `usb  ...  SSK Portable SSD 128GB` (par exemple `sda`), puis :

```sh
DISK=/dev/sda   # ⚠️ remplace par TON nom de clé
lsblk "$DISK"   # vérifie : ~119G, pas nvme0n1 ni nvme1n1
```

> ⚠️ **Vérifie trois fois.** `nvme0n1` = Pop!_OS, `nvme1n1` = Windows. Se
> tromper de disque les efface.

## 2. Partitionner

```sh
# Démonte la clé si Pop!_OS l'a montée automatiquement
sudo umount "$DISK"?* 2>/dev/null

sudo wipefs -a "$DISK"
sudo parted -s "$DISK" -- \
  mklabel gpt \
  mkpart NIXBOOT fat32 1MiB 1GiB \
  set 1 esp on \
  mkpart NIXCRYPT 1GiB 100%

lsblk "$DISK"   # doit montrer ${DISK}1 (1G) et ${DISK}2 (~118G)
```

## 3. Formater et chiffrer

```sh
sudo mkfs.fat -F 32 -n NIXBOOT "${DISK}1"

# Choisis une phrase de passe : elle sera demandée à chaque démarrage
sudo cryptsetup luksFormat --type luks2 --label NIXCRYPT "${DISK}2"
sudo cryptsetup open "${DISK}2" cryptroot

sudo mkfs.btrfs -L nixos /dev/mapper/cryptroot
```

## 4. Créer les sous-volumes et monter

```sh
sudo mount /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@ /mnt/@home /mnt/@nix
sudo umount /mnt

sudo mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/home /mnt/nix /mnt/boot
sudo mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
sudo mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
sudo mount -o fmask=0077,dmask=0077 "${DISK}1" /mnt/boot

findmnt -R -l /mnt   # 4 points de montage : /mnt, /mnt/home, /mnt/nix, /mnt/boot
```

## 5. Installer

```sh
cd ~/Developer/nixos-config
git pull

# Outils d'installation NixOS, à la même version que la config
nix shell .#nixosConfigurations.usb.pkgs.nixos-install-tools

# Dans ce shell :
sudo env "PATH=$PATH" nixos-install --root /mnt --flake .#usb --no-root-passwd
```

Ça télécharge tout le système (plusieurs Go) : compte 10 à 40 minutes.

> **Sans VPN / si c'est très lent** : ajoute les miroirs chinois du cache
> Nix (même signature que le cache officiel) à la commande :
>
> ```sh
> sudo env "PATH=$PATH" nixos-install --root /mnt --flake .#usb --no-root-passwd \
>   --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10 https://mirrors.ustc.edu.cn/nix-channels/store?priority=20 https://cache.nixos.org"
> ```
>
> `priority` fait passer les miroirs avant le cache officiel. Les miroirs
> chinois refusent souvent les connexions venant d'un VPN : déconnecte
> Mullvad pour les utiliser.

## 6. Mot de passe utilisateur

L'utilisateur `mael` n'a pas encore de mot de passe (nécessaire pour se
connecter, `sudo` et déverrouiller l'écran) :

```sh
sudo env "PATH=$PATH" nixos-enter --root /mnt -c 'passwd mael'
```

Puis quitte le `nix shell` (`exit`).

## 7. Démonter proprement

```sh
sudo umount -R /mnt
sudo cryptsetup close cryptroot
```

## 8. Démarrer sur la clé

1. Redémarre et entre dans le BIOS : **désactive le Secure Boot** (et
   vérifie que le démarrage USB est autorisé).
2. Redémarre, appuie sur la **touche du menu de démarrage**, choisis la clé
   (SSK / UEFI USB).
3. systemd-boot → NixOS → **phrase de passe LUKS** → écran de connexion
   (greetd) → Hyprland.

Sans la clé branchée, le PC démarre sur Pop!_OS comme avant.

## 9. Après le premier démarrage

Récupère le dépôt pour pouvoir faire des mises à jour :

```sh
git clone https://github.com/mael-app/nixos-config ~/nixos-config
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#usb
```

L'échelle de l'écran est réglée dans `hosts/usb/configuration.nix`
(`scale = 1.25`). Valeurs valides pour 2560x1600 : `1`, `1.0667`, `1.25`,
`1.3333`, `1.6`, `2`.

## Dépannage

| Problème | Solution |
| --- | --- |
| La clé n'apparaît pas dans le menu de démarrage | Secure Boot encore actif, ou démarrage USB désactivé dans le BIOS |
| Windows demande la clé BitLocker | Normal après un changement du Secure Boot : entre la clé de récupération |
| « waiting for device /dev/disk/by-label/NIXCRYPT » | Branche la clé sur un port USB directement sur le PC (pas un hub) |
| Wi-Fi absent | `nmtui` pour se connecter, ou l'icône réseau dans la barre |
| Espace disque plein | `sudo nix-collect-garbage -d` (un nettoyage automatique tourne déjà chaque semaine) |

Ne débranche jamais la clé pendant que NixOS tourne.
