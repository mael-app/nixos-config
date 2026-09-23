# Remplacer Pop!_OS par NixOS sur le disque interne

L'installation se fait **depuis la clé USB NixOS**, qui contient déjà tout
ce qu'il faut. Si quelque chose se passe mal, la clé reste un système de
secours complet.

Windows n'est pas touché : il est sur l'autre disque (`nvme1n1`), et le
script refuse tout disque contenant un volume BitLocker.

## Disposition du disque interne (`nvme0n1`, 954 Go)

| Partition | Taille | Contenu |
| --- | --- | --- |
| `LAPBOOT` | 1 Gio | FAT32, démarrage (systemd-boot) |
| `LAPCRYPT` | 199 Gio | LUKS2 → btrfs `nixos-sys` : sous-volumes `@` (racine) et `@nix` |
| `LAPHOME` | le reste (~754 Go) | LUKS2 → btrfs `nixos-home` : sous-volume `@home` |

`/home` est dans son **propre volume chiffré** : tu peux réinstaller le
système sans toucher à tes données. Les deux volumes partagent la même
phrase de passe, et systemd la garde en mémoire le temps du démarrage :
tu ne la tapes qu'une fois.

Pour changer la taille du système :
`SYS_SIZE=300GiB bash scripts/install-laptop.sh`

## 0. Avant de commencer

- [ ] **Sauvegarde Pop!_OS** : le disque est entièrement effacé. Pousse tes
      dépôts Git, copie le reste sur un disque externe, et n'oublie pas les
      clés SSH/GPG et les fichiers de config.
- [ ] Clé de récupération BitLocker notée (par précaution).

## 1. Installer

Démarre sur la clé USB, connecte-toi au Wi-Fi, puis :

```sh
git clone https://github.com/mael-app/nixos-config ~/nixos-config
cd ~/nixos-config
bash scripts/install-laptop.sh
```

Le script vérifie le disque, demande de taper `EFFACER`, puis fait tout :
partitionnement, chiffrement, formatage, installation, mot de passe de
`mael`, démontage.

## 2. Premier démarrage

Redémarre et **retire la clé**. NixOS démarre depuis le disque interne :
il s'enregistre cette fois dans le BIOS (`canTouchEfiVariables = true`).

Tape la phrase de passe, puis connecte-toi.

## 3. Déverrouillage automatique par le TPM

Pour ne plus taper la phrase à chaque démarrage :

```sh
cd ~/nixos-config
bash scripts/enroll-tpm.sh
```

La puce TPM du portable déverrouille alors les deux volumes. La phrase de
passe reste utilisable : si le TPM refuse (BIOS mis à jour, Secure Boot
changé, disque déplacé sur une autre machine), elle est redemandée.

## 4. Nettoyage

L'entrée de démarrage « Pop!_OS » reste dans le BIOS sans plus rien
derrière :

```sh
sudo efibootmgr              # repère le numéro de Pop!_OS
sudo efibootmgr -b <n> -B    # supprime l'entrée
```

Windows reste accessible par le menu de démarrage du BIOS.

## Mises à jour

```sh
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#laptop
```

## Dépannage

| Problème | Solution |
| --- | --- |
| « le disque porte le système en cours d'exécution » | Le script vise `/dev/nvme0n1` par défaut ; vérifie avec `lsblk` et corrige avec `TARGET=...` |
| Le système ne démarre pas après l'installation | Démarre sur la clé USB, remonte les volumes et relance `bash scripts/install-laptop.sh --install-only` |
| La phrase de passe est demandée deux fois | Le cache de systemd n'a pas fonctionné : vérifie que `boot.initrd.systemd.enable` est bien activé |
| Le TPM redemande la phrase | État du Secure Boot ou du BIOS modifié : relance `scripts/enroll-tpm.sh` |
