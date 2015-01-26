#!/bin/bash
set -uo pipefail
src=/havana/src/llvm

function cleanup {
    cd $src
    mv -f .newbuild .oldbuild
}
trap cleanup EXIT

cd $src

svn up . tools/clang tools/clang/tools/extra projects/compiler-rt projects/libcxx projects/libcxxabi | tee build.log

svnversion CREDITS.TXT > .newbuild
cmp .newbuild .oldbuild &> /dev/null

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 10 minutes." | tee -a build.log
    sleep 10m
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -rf build; mkdir build; cd build

export CFLAGS="-mfloat-abi=hard -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -fuse-ld=gold"
export CXXFLAGS=$CFLAGS
CC=clang CXX=clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_ENABLE_PIC=ON -DLLVM_TARGETS_TO_BUILD=ARM -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=/havana/dist/llvm -DLIBCXXABI_USE_LLVM_UNWINDER=ON -G "Ninja" .. | tee -a ../build.log

ninja | tee -a ../build.log

# Test manually
./bin/llvm-lit -v -j4 test | tee -a ../build.log
./bin/llvm-lit -v -j4 tools/clang/test | tee -a ../build.log
./bin/llvm-lit -v -j4 --param compile_flags="-mfpu=vfpv3-d16" projects/libcxx/test | tee -a ../build.log
./bin/llvm-lit -v -j4 --param link_flags="-lgcc_s" projects/libcxxabi/test | tee -a ../build.log

rm -rf /havana/dist/llvm
ninja install/strip

cd ..

version=3.7
revision=$(svnversion CREDITS.TXT)
cd /havana/dist

rm $PWD/llvm/lib/libc++.so
cat > $PWD/llvm/lib/libc++.so <<EOF
GROUP ( libc++.so.1 libc++abi.so.1 )
EOF

echo "Compressing with xz..."
tar cJf llvm-armv7-$version-r"$revision".tar.xz llvm
echo "Uploading..."
scp llvm-armv7-$version-r"$revision".tar.xz i10z.com:/havana/llvm/armv7
scp /havana/src/llvm/build.log i10z.com:/havana/llvm/armv7/latest-build.log
ssh i10z.com ln -sf /havana/llvm/armv7/llvm-armv7-$version-r"$revision".tar.xz  /havana/llvm/armv7/latest
rm llvm-armv7-*
echo "llvm-armv7-$version-r"$revision".tar.xz uploaded."
