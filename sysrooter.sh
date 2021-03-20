#!/usr/bin/zsh
set -euo errexit

if [[ $(whoami) = "root" ]]; then
    echo "Don't run this script as root."
    exit -1
fi

ARCH=$1
REPOURL=http://download.opensuse.org/ports/$ARCH/tumbleweed/repo/oss
TARGET=$HOME/$ARCH.sysroot

# Create a fake zypp.conf
conf=$(mktemp)
cat << EOF > $conf
[main]
arch=$ARCH
EOF

# Shortcut
function run_zypper {
    sudo ZYPP_CONF=$conf zypper --non-interactive --no-gpg-checks --root $TARGET "$@"
}

# Clean up
sudo rm -rf $TARGET/{bin,boot,etc,home,lib,mnt,opt,root,run,sbin,srv,tmp,usr,var}

# Add default OSS repo
run_zypper ar $REPOURL repo-oss
run_zypper ref

# Copy emulation binaries
sudo mkdir -p $TARGET/usr/bin
sudo cp /usr/bin/emu /usr/bin/qemu-$ARCH $TARGET/usr/bin

# Create bind mounts
sudo mkdir -p $TARGET/{dev,proc,sys}

# zypper mounts /proc itself
mount -l | grep "$TARGET/dev" &>/dev/null || sudo mount --bind /dev $TARGET/dev

# Install bash and some other required packages
run_zypper in bash glibc-locale-base terminfo
