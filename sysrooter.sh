#!/usr/bin/bash
set -euo errexit

if [ $(whoami) = "root" ]; then
    echo "Don't run this script as root."
    exit -1
fi

# Sanity checks
if [ $# -lt 1 -o $# -gt 2 -o $# -eq 2 -a "${2:-}" != "--shell" ]; then
    echo "Usage: $0 <arch> --shell"
    echo "Supported architectures: armv7hl, aarch64, ppc64, ppc64le"
    exit 0
fi

if [ "$1" != "armv7hl" -a "$1" != "aarch64" -a \
     "$1" != "ppc64"   -a "$1" != "ppc64le" ]; then
    echo "$1 is not supported, supported architectures: armv7hl, aarch64, ppc64, ppc64le"
    exit 0
fi

ARCH=$1
QEMU_SUFFIX=$1

if [[ "$ARCH" == ppc* ]]; then
    REPOURL=http://download.opensuse.org/ports/ppc/tumbleweed/repo/oss
else
    REPOURL=http://download.opensuse.org/ports/$ARCH/tumbleweed/repo/oss
fi

ROOT=/usr/lib/sysroots
TARGET=$ROOT/$ARCH

sudo mkdir -p $ROOT

if [ "$ARCH" = "armv7hl" ]; then
    QEMU_SUFFIX=arm
fi

# Create a fake zypp.conf
conf=$(mktemp)
cat << EOF > $conf
[main]
arch=$ARCH
EOF

if [ $# -eq 2 -a "${2:-}" == "--shell" ]; then
    sudo chroot $TARGET
    exit 0
fi

# Shortcut
function run_zypper {
    sudo ZYPP_CONF=$conf zypper --non-interactive --no-gpg-checks --root $TARGET "$@"
}

if [ -e $TARGET ]; then
    read -p "$TARGET already exists do you want to re-create it? (y/n) "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Clean up
        sudo rm -rf $TARGET/{bin,boot,etc,home,lib,mnt,opt,root,run,sbin,srv,tmp,usr,var}
    else
        echo "Ok, exiting..."
        exit 0
    fi
fi

# Add default OSS repo
run_zypper ar $REPOURL repo-oss
run_zypper ref

# Copy emulation binaries
sudo mkdir -p $TARGET/usr/bin
sudo cp /usr/bin/emu /usr/bin/qemu-$QEMU_SUFFIX $TARGET/usr/bin

# Create /dev for bind mount
sudo mkdir -p $TARGET/dev

# zypper mounts /proc itself
mount -l | grep "$TARGET/dev" &>/dev/null || sudo mount --bind /dev $TARGET/dev

# Install bash and some other required packages
run_zypper in bash glibc-locale-base terminfo coreutils-single python3

sudo umount -l $TARGET/dev
