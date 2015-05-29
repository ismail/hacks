#!/usr/bin/env zsh
set -euo pipefail

GCC_VERSION=5.1.1
GDB_VERSION=7.9.1
SRC_ROOT=/havana/mingw-w64-build
INSTALL_ROOT=/havana/mingw-w64-$GCC_VERSION
TARGET=x86_64-w64-mingw32

rm -rf $INSTALL_ROOT
cd $SRC_ROOT
pull gcc-5-branch mingw-w64

cd mingw-w64
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET \
             --prefix=$INSTALL_ROOT/x86_64-w64-mingw32 \
             --with-tools=all --enabel-sdk-all \
             --enable-secure-api --disable-lib32
make -j$(nproc)
make install-strip

cd ../mingw-w64-libraries/winpthreads
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT/x86_64-w64-mingw32
make -j$(nproc)
make install-strip

mkdir -p $INSTALL_ROOT/mingw/include

cd $SRC_ROOT

rm -rf combined; mkdir combined; cd combined
ln -s ../cloog-* cloog
ln -s ../gmp-* gmp
ln -s ../isl-* isl
ln -s ../mpfr-* mpfr
ln -s ../mpc-* mpc
ln -s ../gcc-5-branch/* .
ln -s ../binutils-*/* . || true
cd ..

rm -rf build; mkdir build; cd build

../combined/configure --build=x86_64-suse-linux-gnu --host=$TARGET --target=$TARGET \
                      --prefix=$INSTALL_ROOT --with-sysroot=$INSTALL_ROOT \
                      --disable-gcov-tool --disable-multilib --disable-nls \
                      --disable-win32-registry --enable-checking=release \
                      --enable-languages=c,c++,fortran --enable-fully-dynamic-string \
                      --enable-libgomp --enable-threads=win32 --disable-werror \
                      --disable-libvtv --with-arch=corei7 --with-tune=haswell

make -j$(nproc)
make install

cd ..
cd gdb-$GDB_VERSION
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT --disable-nls
make -j$(nproc)
make install

cd $INSTALL_ROOT
$TARGET-strip bin/* libexec/gcc/$TARGET/$GCC_VERSION/* || true
rm -rf libexec/gcc/$TARGET/$GCC_VERSION/install-tools
rm -rf mingw/include
rm bin/ld.bfd.exe
cd ..

f=mingw-w64-$GCC_VERSION-$(date +%Y%m%d)
7z a -t7z -m0=lzma2 -mx=9 -mmt$(nproc) -ms=on $f.7z mingw-w64-$GCC_VERSION
scp $f.7z i10z.com:/havana/mingw-w64
ssh i10z.com ln -sf /havana/mingw-w64/$f.7z /havana/mingw-w64/latest.7z
rm $f.7z
