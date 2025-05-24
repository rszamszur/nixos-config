#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p git
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz

if [ -n "$DEBUG" ]; then
    set -x
fi

set -o errexit
set -o nounset
set -o pipefail

TARGET_DRIVE=/dev/nvme1n1
NIXOS_HOST="fenrir"

# EFI system partition on a GUID Partition Table is identified by the partition type GUID C12A7328-F81F-11D2-BA4B-00A0C93EC93B
sfdisk "$TARGET_DRIVE" << EOF
label: gpt
,1000M,C12A7328-F81F-11D2-BA4B-00A0C93EC93B
;
EOF

mkfs.vfat -n boot "$TARGET_DRIVE"p1
mkfs.btrfs -L root "$TARGET_DRIVE"p2
mount "$TARGET_DRIVE"p2 /mnt
mkdir /mnt/boot
mount "$TARGET_DRIVE"p1 /mnt/boot

nixos-generate-config --root /mnt

mkdir /mnt/var
pushd /mnt/var
git clone https://github.com/rszamszur/nixos-config.git
popd

pushd /mnt/etc/nixos
mv configuration.nix configuration.generated.nix
ln -s ../../var/nixos-config/hosts/$NIXOS_HOST/configuration.nix configuration.nix
mv hardware-configuration.nix /mnt/var/nixos-config/hosts/$NIXOS_HOST
ln -s ../../var/nixos-config/hosts/$NIXOS_HOST/hardware-configuration.nix hardware-configuration.nix
popd

nixos-install --no-root-password --flake /mnt/var/nixos-config#$NIXOS_HOST