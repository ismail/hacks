#!/usr/bin/env zsh
set -euo pipefail

if [ -z ${1:-} ]; then
    DIRECTORY_NAME=gcc-5-branch
elif [ x${1:-} = "xtrunk" ]]; then
    DIRECTORY_NAME=gcc
else
    echo "Unknown build type: $1"
    exit 1
fi

SRC_ROOT=/havana/mingw-w64-build
LOCAL_MINGW_ROOT=/usr/x86_64-w64-mingw32/sys-root/mingw
TARGET=x86_64-w64-mingw32

GDB_VERSION=7.9.1
GCC_VERSION=$(cat $SRC_ROOT/$DIRECTORY_NAME/gcc/BASE-VER)
INSTALL_ROOT=/havana/mingw-w64-$GCC_VERSION

rm -rf $INSTALL_ROOT
cd $SRC_ROOT
pull $GCC_VERSION mingw-w64

cd mingw-w64
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET \
             --prefix=$INSTALL_ROOT/x86_64-w64-mingw32 \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --with-tools=all --enable-sdk=all \
             --enable-secure-api --disable-lib32 --disable-shared
make -j$(nproc)
make install-strip

cd ../mingw-w64-libraries/winpthreads
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT/x86_64-w64-mingw32 \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --disable-shared
make -j$(nproc)
make install-strip

mkdir -p $INSTALL_ROOT/mingw/include

cd $SRC_ROOT

rm -rf combined-$GCC_VERSION; mkdir combined-$GCC_VERSION; cd combined-$GCC_VERSION
ln -s ../cloog-* cloog
ln -s ../gmp-* gmp
ln -s ../isl-* isl
ln -s ../mpfr-* mpfr
ln -s ../mpc-* mpc
ln -s ../$DIRECTORY_NAME/* .
ln -s ../binutils-*/* . || true
cd ..

rm -rf build-$GCC_VERSION; mkdir build-$GCC_VERSION; cd build-$GCC_VERSION

../combined-$GCC_VERSION/configure --build=x86_64-suse-linux-gnu --host=$TARGET --target=$TARGET \
                      --prefix=$INSTALL_ROOT --with-sysroot=$INSTALL_ROOT \
                      --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
                      --disable-gcov-tool --disable-multilib --disable-nls \
                      --disable-win32-registry --enable-checking=release \
                      --enable-languages=c,c++,fortran --enable-fully-dynamic-string \
                      --enable-libgomp --enable-threads=win32 --disable-werror \
                      --disable-libvtv --disable-shared --with-arch=corei7 \
                      --with-tune=haswell --with-system-zlib --disable-nls \
                      --without-included-gettext --enable-linker-build-id

make -j$(nproc)
make install

cd ..
cd gdb-$GDB_VERSION
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --disable-shared --disable-nls
make -j$(nproc)
make install

cd $INSTALL_ROOT
cp $LOCAL_MINGW_ROOT/bin/{libexpat-1,zlib1}.dll bin
rm -rf libexec/gcc/$TARGET/$GCC_VERSION/install-tools
rm -rf mingw/include
rm bin/ld.bfd.exe $TARGET/bin/ld.bfd.exe
$TARGET-strip bin/* libexec/gcc/$TARGET/$GCC_VERSION/* || true
cd ..

f=mingw-w64-$GCC_VERSION-$(date +%Y%m%d)
7z a -t7z -m0=lzma2 -mx=9 -mmt$(nproc) -ms=on $f.7z mingw-w64-$GCC_VERSION
scp $f.7z i10z.com:/havana/mingw-w64
ssh i10z.com ln -sf /havana/mingw-w64/$f.7z /havana/mingw-w64/latest.7z
rm $f.7z
