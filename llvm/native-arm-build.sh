#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

got_control_c=0

control_c()
{
    if [ $got_control_c -eq 1 ]; then
        echo "Exiting".
        exit 0
    fi

    got_control_c=1
    echo "CTRL-C again to exit"
}

trap control_c SIGINT

cd /havana/src/llvm
svn up . tools/clang tools/clang/tools/extra projects/compiler-rt projects/libcxx projects/libcxxabi
rm -rf build; mkdir build; cd build

CFLAGS="-mfloat-abi=hard -march=armv7-a -mtune=cortex-a8 -mfpu=vfpv3-d16 -fuse-ld=gold"
CC=clang CXX=clang++ cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PIC=ON -DLLVM_ENABLE_TIMESTAMPS=OFF -DCMAKE_INSTALL_PREFIX=/havana/dist/llvm -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DCMAKE_C_FLAGS=$CFLAGS -DCMAKE_CXX_FLAGS=$CFLAGS -G "Ninja" .. | tee build.log

ninja | tee -a build.log

# Test manually
./bin/llvm-lit -v -j4 test | tee -a build.log
./bin/llvm-lit -v -j4 tools/clang/test | tee -a build.log
./bin/llvm-lit -v -j4 projects/libcxx/test | tee -a build.log
./bin/llvm-lit -v -j4 projects/libcxxabi/test | tee -a build.log

ninja install/strip

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
