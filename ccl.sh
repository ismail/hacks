#!/bin/sh

set -euo pipefail

CLANG_EXTRAS="$CLANG_EXTRAS -fno-color-diagnostics"

f=`mktemp /tmp/prog.XXXXXX`
clang++ -std=c++14 $CLANG_EXTRAS -x c++ -o $f -

$f
rm -f $f

