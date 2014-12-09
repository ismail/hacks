#!/bin/sh

VERSION=12.0
ARCH=$1

if [ -z $ARCH ]; then
    ARCH=x86
fi

cmd /c "C:\\Program Files (x86)\\Microsoft Visual Studio $VERSION\\VC\\vcvarsall.bat" "$ARCH" "&&" "C:\\cygwin64\\bin\\zsh" "--login" "-i"

