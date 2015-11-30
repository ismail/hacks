#!/usr/bin/env zsh

VCPATH=/havana/binaries/msvc2015
export INCLUDE="$PWD/VC/include;$PWD/win_sdk/Include/shared/;$PWD/win_sdk/Include/um/;$PWD/win_sdk/Include/winrt/"
export LIB="$PWD/VC/lib;$PWD/win_sdk/Lib/winv6.3/um/x86"
export WINEDLLOVERRIDES="*msvcr140=n"

wine $VCPATH/VC/bin/cl.exe /EHsc- /nologo "$@"
