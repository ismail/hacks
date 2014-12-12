#!/bin/sh
set -euo pipefail
version=3.6.0

pull . tools/clang

rm -rf dist
mkdir dist
cd dist

cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DPYTHON_EXECUTABLE=C:/Python27/python.exe -DLLVM_BUILD_TESTS=ON .. | tee build.log

ninja | tee -a build.log
ninja check-all | tee -a build.log || true
ninja package | tee -a build.log

cd ..
rev=`git log -1 --format="%h"`
mv dist/LLVM-*.exe ~/dist/LLVM-$version-$rev-win32.exe
mv dist/build.log ~/dist/build-$rev.log

cd ~/dist
ln -sf LLVM-$version-$rev-win32.exe latest.exe
ln -sf build-$rev.log latest.log
