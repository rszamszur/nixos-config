#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash sshfs rsync umount mount
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-25.11.tar.gz

if [ -n "$DEBUG" ]; then
    set -x
fi

set -o errexit
set -o nounset
set -o pipefail

if [[ ! -d "$1" ]]; then
    echo "Provided backup destination dir is not a dir"
    exit 1
fi

mount_dir=$(mktemp -d)
dest_dir="$1/$(date '+%Y-%m-%d')"
mkdir "$dest_dir"
sshfs remarkable:/home/root "$mount_dir"
rsync -av "$mount_dir/" "$dest_dir"
umount "$mount_dir"
