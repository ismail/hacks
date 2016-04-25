#!/usr/bin/env zsh

set -euo pipefail
trap cleanup EXIT

i=$(mktemp /tmp/code.XXXXXX.cpp)
f=$(mktemp /tmp/prog.XXXXXX.exe)

cleanup () {
    rm -f $i $f
}


if [ -d /cygdrive ]; then
    f=$(cygpath -w $f)
    i=$(cygpath -w $i)
    chmod +x $f
fi

cat /dev/stdin > $i

clang++ -fno-color-diagnostics -std=c++14 -Wall -Wextra -o $f $i

$f
