#!/bin/zsh

set -euo pipefail
trap cleanup EXIT

cleanup () {
    rm -f $i $f
}

i=$(mktemp /tmp/code.XXXXXX.cpp)
f=$(mktemp /tmp/prog.XXXXXX.exe)

if [ -d /cygdrive ]; then
    chmod +x $f
fi

cat /dev/stdin > $i

clang++ -std=c++14 ${=EXTRA_CLANG_FLAGS} -o $f(+cyg) $i(+cyg)

$f
