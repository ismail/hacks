#!/bin/bash
set -uo pipefail
IFS=$'\n\t'

cd /havana/src/llvm
svn up . tools/clang tools/clang/tools/extra projects/compiler-rt projects/libcxx projects/libcxxabi

svnversion CREDITS.TXT > .newbuild
cmp .newbuild .oldbuild &> /dev/null

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 10 minutes."
    sleep 10m
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -rf build; mkdir build; cd build

CFLAGS="-mfloat-abi=hard -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -fuse-ld=gold"
CC=clang CXX=clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_ENABLE_PIC=ON -DLLVM_TARGETS_TO_BUILD=ARM -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=/havana/dist/llvm -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DCMAKE_C_FLAGS=$CFLAGS -DCMAKE_CXX_FLAGS=$CFLAGS -G "Ninja" .. | tee build.log

ninja | tee -a build.log

# Test manually
./bin/llvm-lit -v -j4 test | tee -a build.log
./bin/llvm-lit -v -j4 tools/clang/test | tee -a build.log
./bin/llvm-lit -v -j4 projects/libcxx/test | tee -a build.log
./bin/llvm-lit -v -j4 projects/libcxxabi/test | tee -a build.log

rm -rf /havana/dist/llvm
ninja install/strip

mv .newbuild .oldbuild

version=3.6
revision=`svnversion ../CREDITS.TXT`
cd /havana/dist

rm $PWD/llvm/lib/libc++.so
cat > $PWD/llvm/lib/libc++.so <<EOF
GROUP ( libc++.so.1 libc++abi.so.1 )
EOF

echo "Compressing with xz..."
tar cJf llvm-armv7-$version-r"$revision".tar.xz llvm
echo "Uploading..."
scp llvm-armv7-$version-r"$revision".tar.xz i10z.com:/havana/llvm/checked
scp /havana/src/llvm/build/build.log i10z.com:/havana/llvm/checked/latest-build.log
ssh i10z.com ln -sf /havana/llvm/checked/llvm-armv7-$version-r"$revision".tar.xz  /havana/llvm/checked/latest
rm llvm-armv7-*
echo "llvm-armv7-$version-r"$revision".tar.xz uploaded."
