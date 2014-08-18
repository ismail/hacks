#!/bin/zsh

root=/havana/llvm
svnversion=`svnversion $root/CREDITS.TXT`
version=3.6
target=armv7l-unknown-linux-gnueabihf

cd $root &&
svn up && svn up tools/clang && svn up tools/clang/tools/extra && svn up projects/compiler-rt && svn up projects/libcxx && svn up projects/libcxxabi &&

rm -rf build && mkdir build && cd build &&

CC=arm-clang CXX=arm-clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PIC=ON -DLLVM_TARGET_ARCH=ARM -DLLVM_TARGETS_TO_BUILD=all -DLLVM_DEFAULT_TARGET_TRIPLE=$target -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=$PWD/llvm -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DENABLE_CLANG_EXAMPLES=OFF -DLLVM_BUILD_TESTS=OFF -G "Ninja" .. &&

ninja &&
ninja install/strip &&
echo "Creating the tarball..." &&
tar cJf llvm-armv7-$version-r$svnversion.tar.xz llvm &&
scp llvm-armv7-*.tar.xz i10z.com:/havana/llvm &&
ssh i10z.com ln -sf /havana/llvm/llvm-armv7-$version-r$svnversion.tar.xz /havana/llvm/latest &&
cd .. &&
rm -rf $root/build &&
echo "Done."
