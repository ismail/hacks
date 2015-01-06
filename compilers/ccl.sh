#!/bin/sh

set -euo pipefail
trap cleanup EXIT

CLANG_EXTRAS="$CLANG_EXTRAS -fno-color-diagnostics"

cleanup () {
    rm -f $i $f
}

i=`mktemp /tmp/code.XXXXXX.cpp`
f=`mktemp /tmp/prog.XXXXXX`

if [ -d /cygdrive ]; then
    chmod +x $f
    i=`cygpath -m $i`
    f=`cygpath -m $f`
fi

cat /dev/stdin > $i

clang++ -std=c++14 $CLANG_EXTRAS -o $f $i

$f
