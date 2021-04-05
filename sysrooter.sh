#!/usr/bin/env bash
set -euo errexit

usage() {
    echo "Usage: $0 -a|--arch <arch> -s|--shell --leap"
    echo "Supported architectures: ${!arches[@]}"
    exit 1
}

run_zypper() {
    sudo ZYPP_CONF=$conf zypper --non-interactive --root $TARGET "$@"
}

if [ $(whoami) = "root" ]; then
    echo "Don't run this script as root."
    exit -1
fi

ARCH=''
QEMU_SUFFIX=''
CHROOT=0
DISTRO_PATH="tumbleweed"
DISTRO_NAME="tumbleweed"
LEAP_VERSION="15.2"
ROOT="/usr/lib/sysroots"
BASE_URL="https://mirrorcache.opensuse.org/ports/"

declare -A arches=([armv7hl]=1 [aarch64]=1 [ppc64]=1 \
                   [ppc64le]=1 [riscv64]=1 [s390x]=1)

opts=$(getopt -l "arch:,shell,leap,help" -o "a:s:l:h" -- "$@")
eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--arch)
            ARCH=$2
            QEMU_SUFFIX=$ARCH
            shift 2
            ;;
        -s|--shell)
            CHROOT=1
            shift 1
            ;;
        -l|--leap)
            DISTRO_PATH="/distribution/leap/$LEAP_VERSION/"
            DISTRO_NAME="leap"
            shift 1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

[[ -z $ARCH ]] && echo "--arch is a required argument." && usage && exit 1

if [[ -z ${arches[$ARCH]:-} ]]; then
    echo "$ARCH is not supported, supported architectures: ${!arches[@]}"
    exit 1
fi

TARGET=$ROOT/$ARCH-$DISTRO_NAME
[[ $DISTRO_NAME = "leap" ]] && TARGET=$TARGET-$LEAP_VERSION

cleanup() {
    sudo umount -l $TARGET/dev || true
    sudo umount -l $TARGET/proc || true
}
trap cleanup EXIT

if [[ $CHROOT -eq 1 ]]; then
    [[ ! -d $TARGET ]] && echo "$TARGET does not exist" && exit 1
    sudo chroot $TARGET && exit 0
fi

if [[ "$ARCH" == ppc* ]]; then
    REPOURL="$BASE_URL"/ppc/"$DISTRO_PATH"/repo/oss
elif [[ "$ARCH" == riscv64 ]]; then
    [[ $DISTRO_NAME = "leap" ]] && echo "Leap doesn't support riscv64." && exit 1
    REPOURL="$BASE_URL"/riscv/"$DISTRO_PATH"/repo/oss
elif [[ "$ARCH" = s390x ]]; then
    [[ $DISTRO_NAME = "leap" ]] && echo "Leap doesn't support s390x." && exit 1
    REPOURL="$BASE_URL"/zsystems/"$DISTRO_PATH"/repo/oss
else
    REPOURL="$BASE_URL"/"$ARCH"/"$DISTRO_PATH"/repo/oss
fi

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
run_zypper ar -f $REPOURL repo-oss
run_zypper --gpg-auto-import-keys ref

# Ubuntu...
[[ -f /usr/bin/qemu-$QEMU_SUFFIX-static ]] && QEMU_SUFFIX="$QEMU_SUFFIX"-static

# Copy emulation binaries
sudo mkdir -p $TARGET/usr/bin
sudo cp /usr/bin/emu /usr/bin/qemu-$QEMU_SUFFIX $TARGET/usr/bin

# Create /dev, /proc for bind mount
sudo mkdir -p $TARGET/dev $TARGET/proc

mount -l | grep "$TARGET/dev" &>/dev/null || sudo mount --bind /dev $TARGET/dev
mount -l | grep "$TARGET/proc" &>/dev/null || sudo mount --bind /proc $TARGET/proc

# Install bash and some other required packages
run_zypper in bash glibc-locale-base terminfo coreutils python3


