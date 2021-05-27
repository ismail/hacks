#!/bin/bash

set -uo pipefail

usage() {
    echo "Usage: $0 <sysroot>"
    echo "Convert all the symlinks in <sysroot> to be relative."
    exit 0
}

if [[ $# -lt 1 ]]; then
    usage
fi

for link in $(find $1 -type l); do
    dest=$(readlink $link)
    if [[ $dest == /* ]]; then 
        echo "Fixing $link -> $dest"
        ln -sfr $1$dest $link
    fi
done
