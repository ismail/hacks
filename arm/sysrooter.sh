#!/usr/bin/zsh

if [[ $(whoami) = "root" ]]; then
    echo "Don't run this script as root."
    exit -1
fi

ARCH=aarch64
#ARCH=armv7hl
REPOURL=http://download.opensuse.org/ports/$ARCH/tumbleweed/repo/oss
TARGET=$HOME/$ARCH.sysroot

# Clean up
sudo rm -rf $TARGET/{bin,boot,etc,home,lib,mnt,opt,root,run,sbin,srv,tmp,usr,var}

# Add default OSS repo
sudo zypper --root $TARGET ar $REPOURL repo-oss
sudo zypper --non-interactive --no-gpg-checks --root $TARGET ref

# Copy emulation binaries
sudo mkdir -p $TARGET/usr/bin
sudo cp /usr/bin/emu /usr/bin/qemu-$ARCH $TARGET/usr/bin

# Create bind mounts
sudo mkdir -p $TARGET/{dev,proc,sys}

# zypper mounts /proc itself
sudo mount --bind /dev $TARGET/dev || :

# Install bash and some other required packages
sudo zypper --non-interactive --root $PWD/$ARCH.sysroot in bash
sudo zypper --non-interactive --root $PWD/$ARCH.sysroot in glibc-locale-base terminfo
