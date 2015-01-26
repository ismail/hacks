#!/usr/bin/env zsh

VCPATH=/havana/binaries/msvc2013
export INCLUDE="$VCPATH/VC/include;$VCPATH/win8sdk/Include/shared/;$VCPATH/win8sdk/Include/um/;$VCPATH/win8sdk/Include/winrt/"
export LIB="$VCPATH/VC/lib;$VCPATH/win8sdk/Lib/winv6.3/um/x86"
export WINEDEBUG=-all
export WINEDLLOVERRIDES="*msvcr120=n"

input=$@[-1]
obj=${input:t:r}.obj

wine $VCPATH/VC/bin/cl.exe /EHsc- /nologo "$@[1,-2]" $(winepath -w $input) | sed '1d'
rm -f $obj
