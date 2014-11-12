#!/bin/zsh
set -euo pipefail
IFS=$'\n\t'

revision=$1
root=/havana/llvm
version=3.6
target=armv7l-unknown-linux-gnueabihf

cd $root
svn up -r$revision . tools/clang tools/clang/tools/extra projects/compiler-rt projects/libcxx projects/libcxxabi

svnversion=`svnversion $root/CREDITS.TXT`
rm -rf build; mkdir build; cd build

sudo ~/hacks/arm-emu-binfmt.sh
CC=arm-clang CXX=arm-clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PIC=ON -DLLVM_TARGET_ARCH=ARM -DLLVM_TARGETS_TO_BUILD=all -DLLVM_DEFAULT_TARGET_TRIPLE=$target -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=$PWD/llvm -DLLVM_BUILD_EXAMPLES=OFF -DENABLE_CLANG_EXAMPLES=OFF -DLLVM_INCLUDE_TESTS=OFF -G "Ninja" ..

ninja
ninja install/strip

echo "Creating the tarball..."
tar cJf llvm-armv7-$version-r$svnversion.tar.xz llvm
scp llvm-armv7-*.tar.xz i10z.com:/havana/llvm
ssh i10z.com ln -sf /havana/llvm/llvm-armv7-$version-r$svnversion.tar.xz /havana/llvm/latest
cd ..
rm -rf $root/build
sudo ~/hacks/arm-emu-binfmt.sh reset
echo "Done."

