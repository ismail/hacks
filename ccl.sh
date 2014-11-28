#!/bin/sh

set -euo pipefail

f=`mktemp /tmp/prog.XXXXXX`
clang++ -std=c++14 $CLANG_EXTRAS -x c++ -o $f -

$f
rm -f $f

