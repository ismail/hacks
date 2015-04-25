#!/usr/bin/env zsh
VERSION=12.0

name=${0:t}
case $name in
    vs|vs32)
        ARCH=x86
        ;;
    vs64)
        ARCH=x64
        ;;
esac

cmd /c "C:/Program Files (x86)/Microsoft Visual Studio $VERSION/VC/vcvarsall.bat" "$ARCH" "&&" zsh "-i"

