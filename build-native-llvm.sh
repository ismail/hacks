#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd /havana/src/llvm
svn up . tools/clang tools/clang/tools/extra projects/compiler-rt projects/libcxx projects/libcxxabi
rm -rf build; mkdir build; cd build

CFLAGS="-mfloat-abi=hard -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -fuse-ld=gold"
CC=clang CXX=clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PIC=ON -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=/havana/dist/llvm -DCMAKE_C_FLAGS=$CFLAGS -DCMAKE_CXX_FLAGS=$CFLAGS -G "Ninja" .. 

ninja

# Test manually
./bin/llvm-lit -v -j4 test
./bin/llvm-lit -v -j4 tools/clang/test
./bin/llvm-lit -v -j4 projects/libcxx/test
./bin/llvm-lit -v -j4 projects/libcxxabi/test

ninja install/strip

version=3.6
revision=`svnversion ../CREDITS.TXT`
cd /havana/dist
echo "Compressing with xz..."
tar cJf llvm-armv7-$version-r"$revision".tar.xz llvm
echo "Uploading..."
scp llvm-armv7-$version-r"$revision".tar.xz i10z.com:/havana/llvm/checked
ssh i10z.com ln -sf /havana/llvm/checked/llvm-armv7-$version-r"$revision".tar.xz  /havana/llvm/checked/latest
rm llvm-armv7-*
echo "llvm-armv7-$version-r"$revision".tar.xz uploaded."
