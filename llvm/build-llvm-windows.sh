#!/bin/sh
set -euo pipefail
version=3.6.0

svn up . tools/clang tools/clang/tools/extra

rm -rf dist
mkdir dist
cd dist

export PATH="/cygdrive/c/Program Files/SlikSvn/bin":$PATH
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DPYTHON_EXECUTABLE=C:/Python27/python.exe -DLLVM_BUILD_TESTS=ON ..

ninja | tee build.log
ninja check-all | tee build.log
ninja package | tee build.log

rev=`svn ~/code/llvm/CREDITS.TXT`
mv LLVM-*.exe ~/dist/LLVM-$version-$rev-win32.exe
cd ~/dist
ln -sf LLVM-$version-$rev-win32.exe latest
