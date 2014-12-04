#!/bin/sh

set -euo pipefail

CLANG_EXTRAS="$CLANG_EXTRAS -fno-color-diagnostics"

f=`mktemp /tmp/prog.XXXXXX`

if [ -d /cygdrive ]; then
    chmod +x $f
    f=`cygpath -m $f`
fi

clang++ -std=c++14 $CLANG_EXTRAS -x c++ -o $f -

$f
rm -f $f

