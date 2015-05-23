#!/usr/bin/env zsh
set -euo pipefail

GCC_VERSION=5.1.1
SRC_ROOT=/havana/mingw-w64-build
INSTALL_ROOT=/havana/mingw-w64

rm -rf $INSTALL_ROOT
cd $SRC_ROOT
pull gcc-5-branch mingw-w64

cd mingw-w64
rm -rf build; mkdir build; cd build
../configure --host=x86_64-w64-mingw32 --target=x86_64-w64-mingw32 --prefix=/havana/mingw-w64/x86_64-w64-mingw32 --disable-lib32
make -j$(nproc)
make install-strip

cd ../mingw-w64-libraries/winpthreads
rm -rf build; mkdir build; cd build
../configure --host=x86_64-w64-mingw32 --target=x86_64-w64-mingw32 --prefix=/havana/mingw-w64/x86_64-w64-mingw32
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

../combined/configure --build=x86_64-suse-linux-gnu --host=x86_64-w64-mingw32 --prefix=/havana/mingw-w64 --with-sysroot=/havana/mingw-w64 --target=x86_64-w64-mingw32 --disable-gcov-tool --disable-multilib --disable-nls --disable-win32-registry --enable-checking=release --enable-languages=c,c++,fortran --enable-fully-dynamic-string --enable-libgomp --enable-threads=win32 --disable-werror --disable-libvtv --with-arch=corei7 --with-tune=haswell

make -j$(nproc)
make install

cd $INSTALL_ROOT
x86_64-w64-mingw32-strip bin/* libexec/gcc/x86_64-w64-mingw32/$GCC_VERSION/* || true
rm -rf libexec/gcc/x86_64-w64-mingw32/$GCC_VERSION/install-tools
rm -rf mingw/include
rm bin/ld.bfd
cd ..

tar --exclude-vcs -cf mingw-w64-$GCC_VERSION.tar mingw-w64
xz -6 -T0 mingw-w64-$GCC_VERSION.tar
mv mingw-w64-$GCC_VERSION.tar.xz $HOME
