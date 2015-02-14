#!/usr/bin/env zsh
set -euo pipefail
IFS=$'\n\t'

revision=$1
root=/havana/llvm
rm -rf $root/build
version=3.7
target=armv7l-unknown-linux-gnueabihf

cd $root
svn up -r$revision . tools/clang tools/clang/tools/extra projects/compiler-rt projects/libcxx projects/libcxxabi

svnversion=$(svnversion $root/CREDITS.TXT)
rm -rf build; mkdir build; cd build

CC=arm-clang CXX=arm-clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_ENABLE_PIC=ON -DLLVM_TARGET_ARCH=ARM -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DLLVM_TARGETS_TO_BUILD=ARM -DLLVM_DEFAULT_TARGET_TRIPLE=$target -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=$PWD/llvm -DLLVM_BUILD_EXAMPLES=OFF -DENABLE_CLANG_EXAMPLES=OFF -DLLVM_INCLUDE_TESTS=OFF -G "Ninja" ..

ninja
ninja install/strip

rm $PWD/llvm/lib/libc++.so
cat > $PWD/llvm/lib/libc++.so <<EOF
GROUP ( libc++.so.1 libc++abi.so.1 )
EOF

echo "Creating the tarball..."
tar cJf llvm-armv7-$version-r$svnversion.tar.xz llvm
scp llvm-armv7-*.tar.xz i10z.com:/havana/llvm/armv7-notchecked
ssh i10z.com ln -sf /havana/llvm/armv7-notchecked/llvm-armv7-$version-r$svnversion.tar.xz /havana/llvm/armv7-notchecked/latest

# Bintray upload
curl -T llvm-armv7-$version-r$svnversion.tar.xz -uismail:$(cat ~/.bintray) -H X-Bintray-Package:llvm-armv7-notchecked -H X-Bintray-Version:$version-r$svnversion -H X-Bintray-Publish:1 https://api.bintray.com/content/ismail/llvm/llvm-armv7-$version-r$svnversion.tar.xz

echo "Done."
