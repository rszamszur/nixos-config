# nixos-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![CI](https://github.com/rszamszur/nixos-config/actions/workflows/main.yml/badge.svg)](https://github.com/rszamszur/nixos-config/actions/workflows/main.yml)

Configuration to setup my NixOS instances.

## Hosts configurations health

| Name         | CI Status |
|--------------|-----------|
| draugr | [![build-configs](https://github.com/rszamszur/nixos-config/actions/workflows/draugr.yaml/badge.svg?branch=master)](https://github.com/rszamszur/nixos-config/actions/workflows/draugr.yaml) |
| fenrir | [![build-configs](https://github.com/rszamszur/nixos-config/actions/workflows/fenrir.yaml/badge.svg?branch=master)](https://github.com/rszamszur/nixos-config/actions/workflows/fenrir.yaml) |

## Disk setup - encrypted btrfs

[**Credits for the instructions**](https://blog.kolaente.de/2021/11/installing-nixos-with-encrypted-btrfs-root-device-and-home-manager-from-start-to-finish/)

Figure out what drive you want to use with `fdisk -l` or `lsblk`. You’ll need to use the entire disk, not single partitions.

Run

```bash
fdisk <drive>
```

### Creating partitions

We’ll create two physical partitions with gdisk:

* One efi partition
* One for nixos and everything else

The last one will be a container which will hold nixos and the swap partition.

First, remove all existing partitions from the drive with `d`. It will ask you every time about the partition you want to delete.

Then create the following partitions:

| **Number** | **Type** | **Size** | **What**                                               |
|------------|----------|----------|--------------------------------------------------------|
| 1          | ef00     | +500M    | The (u)efi partition                                   |
| 2          | 8300     |          | The one partition that’s going to hold the os and swap |

### Cryptsetup

Next, we’re going to create an encrypted root container for the os/everything else partition with `cryptsetup`. If your output looks like mine from above, this is the third partition.

Create the encrypted container:

```bash
cryptsetup luksFormat <device>2
```

And open it:

```bash
cryptsetup open <device>2 nixenc
```

`cryptsetup` will ask you for a password on both commands. You will need to enter this after your system is installed on every boot.

Once the container is open, you have a `/dev/mapper/nixenc` device available as if it was a normal disk. Note that we specified the last part of that in the `cryptsetup open` command.

### Creating a volume group

We’ll use a volume group to hold the swap and root partition. We could encrypt them individually, but using a volume group won’t require us to enter the password multiple times when booting the computer.

First, we’ll tell lvm to handle the luks device we just formatted as if it was a physical partition:

```bash
pvcreate /dev/mapper/nixenc
```

Then we’ll create the actual volume group and call it `vg`:

```bash
vgcreate vg /dev/mapper/nixenc
```

Now that we have a volume group, we can finally create the new volumes:

```bash
lvcreate -n swap -L 8GB vg       # the swap partition
lvcreate -n root -l +100%FREE vg # root partition with the os and everything else
```

Both of these new volumes will appear at `/dev/mapper/vg-swap` and `/dev/mapper/vg-root` to format and use them.

### Formatting the new filesystems

To actually use the volumes, you need to format them.

First, set up the boot partition on the first device:

```bash
mkfs.vfat -n boot <device>1
```

Then create and enable the swap partition:

```bash
mkswap /dev/mapper/vg-swap
swapon /dev/mapper/vg-swap
```

Enabling it will make `nixos-generate-config` detect it and put it in your `hardware-configuration.nix`. And you’ll be able to use it during the installation.

Lastly, create the actual btrfs root partition:

```bash
mkfs.btrfs -L root /dev/mapper/vg-root
```

If you want to set up brtfs subvolumes, now is a good time for that.

## Nix installation

Mount the new btrfs partition to `/mnt`:

```bash
mount /dev/mapper/vg-root /mnt
```

And mount the uefi partition to `/mnt/boot`:

```bash
mkdir /mnt/boot
mount <device 1> /mnt/boot
```

Then run

```bash
nixos-generate-config --root /mnt
```

to generate a new nixos config.

### Installation with git

Clone my nixos config to `/var` and then symlink it to `/etc/nixos/configuration.nix` so that nixos will pick it up and use it.

Note that you need to clone the repo to `/mnt` because that’s where we the root os partition is mounted:

```bash
mkdir /mnt/var
cd /mnt/var
git clone git@github.com:rszamszur/nixos-config.git
```

To create the symlink, it’s important to create one with a relative path - nixos is not yet installed in `/` but in `/mnt`. I usually do something like this:

```bash
cd /mnt/etc/nixos
mv configuration.nix configuration.generated.nix
# Choose host to build
ln -s ../../var/nixos-config/hosts/draugr/configuration.nix configuration.nix
```

Usually, it’s a good idea to take a look at the auto generated `hardware-configuration.nix` and add it to the already existing config because it has all disks and everything else detected by `nixos-generate-config`.

### nixos-unstable

You might have references to packages from the nixos unstable channel in your config. I usually add the unstable channel to my nix channels as `nixos-unstable`.

If you don’t have that channel available in nix channels, the installation will fail. To add it:

```bash
nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
```

Refresh the channels so they are actually usable:

```bash
nix-channel --update
```

### Setting the correct boot device

To tell grub the device it should boot from we need to tell it the root device. In order to do that, first figure out which uuid is has.

We’re going to use `lsblk` for that:

```bash
$ lsblk -o name,type,mountpoint,uuid

NAME          TYPE  MOUNTPOINT     UUID
loop0         loop  /nix/.ro-store 
sda           disk                 1980-01-01-00-00-00-00
├─sda1        part  /iso           1980-01-01-00-00-00-00
└─sda2        part                 1234-5678
nvme0n1       disk                 
├─nvme0n1p1   part  /mnt/boot      8C6D-DD63
└─nvme0n1p2   part                 d6f3e071-f449-4aab-87f4-93ee3a3fbab1 # This is the uuid we're looking for
  └─nixenc    crypt                qtCMVj-QKcW-0rcm-Pyud-Fqzc-tA8f-inZp3M
    ├─vg-swap lvm   [SWAP]         a7208e31-c1e7-44b8-895c-d01d0b930508
    └─vg-root lvm   /mnt     
```

Add the following entry to a `boot.nix` or `hardware-configuration.nix` file:

```nixos
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/<the uuid of the root partition from above>";
      preLVM = true;
      allowDiscards = true;
    };
  };
```

### Build it!

Now that everything is set up, we can actually install the nixos system with:

```bash
nixos-install
```

Depending on your configuration, internet speed and hardware, this will take a while.

## Done?

Once nixos-install has finished, reboot your system. If everything went well, it should greet you with a login screen.

## Secrets

Users passwords:

```bash
mkpasswd -m sha-512
```

## Similar repos

* [adisbladis/nixconfig](https://github.com/adisbladis/nixconfig)
* [AleksanderGondek/nixos-config](https://github.com/AleksanderGondek/nixos-config)
* [kczulko/nixos-config](https://github.com/kczulko/nixos-config)
* [yrashk/nix-home](https://github.com/yrashk/nix-home)
* [ttuegel/nixos-config](https://github.com/ttuegel/nixos-config)
* [NobbZ/nixos-config](https://github.com/NobbZ/nixos-config)
* [MatthiasBenaets/nixos-config](https://github.com/MatthiasBenaets/nixos-config)
* [patryk-kozak/nixos-config](https://github.com/patryk-kozak/nixos-config)

## Reference

* [Installing NixOS with encrypted btrfs root device and home-manager from start to finish](https://blog.kolaente.de/2021/11/installing-nixos-with-encrypted-btrfs-root-device-and-home-manager-from-start-to-finish/)

## Useful links

* [Nix package versions](https://lazamar.co.uk/nix-versions)
* [home-manager configuration options](https://rycee.gitlab.io/home-manager/options.html)
* [bennofs/nix-index](https://github.com/bennofs/nix-index)
* [An opinionated guide for developers getting things done using the Nix ecosystem.](https://nix.dev/)
* [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/unstable)
