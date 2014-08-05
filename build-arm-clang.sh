#!/bin/sh

root=/havana/llvm
version=3.6

cd $root &&
svn up && svn up tools/clang && svn up projects/compiler-rt && svn up projects/libcxx && svn up projects/libcxxabi &&

rm -rf build && mkdir build && cd build &&

CC=arm-clang CXX=arm-clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PIC=ON -DLLVM_TARGET_ARCH=ARM -DLLVM_TARGETS_TO_BUILD=ARM -DLLVM_DEFAULT_TARGET_TRIPLE=arm-linux-gnueabihf -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=$PWD/llvm -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DCLANG_ENABLE_ARCMT=OFF -DCLANG_ENABLE_STATIC_ANALYZER=OFF -DENABLE_CLANG_EXAMPLES=OFF -DLLVM_BUILD_TESTS=OFF -G "Ninja" .. &&

ninja &&
ninja install/strip &&
echo -n "Fixing interpreter... " &&
for f in `find llvm -type f`;do patchelf --set-interpreter /lib/ld-linux-armhf.so.3 $f &>/dev/null;done &&
echo "Done." &&
echo "Creating the tarball..." &&
tar cJf llvm-armv7-$version-r`svnversion ../CREDITS.TXT`.tar.xz llvm &&
echo -n "Uploading to Mega... " &&
mega -force put llvm-armv7-$version-*.tar.xz mega:/llvm/ &&
cd ..
rm -rf $root/build &&
echo "Done."
