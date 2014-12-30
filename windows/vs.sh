#!/bin/sh
VERSION=12.0

name=`basename $0`
case $name in
    vs|vs32)
        ARCH=x86
        ;;
    vs64)
        ARCH=x64
        ;;
esac

if [ -f /usr/local/bin/zsh ]; then
    ZSH_PATH="/usr/local/bin/zsh"
elif [ -f /usr/bin/zsh ]; then
    ZSH_PATH="/usr/bin/zsh"
else
    ZSH_PATH="/bin/zsh"
fi

ZSH_PATH=`cygpath -w $ZSH_PATH`

cmd /c "C:/Program Files (x86)/Microsoft Visual Studio $VERSION/VC/vcvarsall.bat" "$ARCH" "&&" "$ZSH_PATH" "--login" "-i"

