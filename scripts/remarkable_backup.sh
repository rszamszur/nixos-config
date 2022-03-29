#!/usr/bin/env bash

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

if ! command -v sshfs &>/dev/null; then
    echo "sshfs is not installed"
    exit 1
fi

if ! command -v rsync &>/dev/null; then
    echo "rsync is not installed"
    exit 1
fi

mount_dir=$(mktemp -d)
sshfs remarkable:/home/root "${mount_dir}"
rsync -av "${mount_dir}" "${1}"
umount "${mount_dir}"
