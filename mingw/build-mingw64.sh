#!/usr/bin/env zsh
set -euo pipefail

if [ -z ${1:-} ]; then
    BRANCH_NAME=master
    UPLOAD_DIRECTORY="6.x"
elif [ x${1:-} = "xstable" ]; then
    BRANCH_NAME=gcc-5-branch
    UPLOAD_DIRECTORY="5.x"
else
    echo "Unknown build type: $1"
    exit 1
fi

SRC_ROOT=/havana/mingw-w64-build
LOCAL_MINGW_ROOT=/usr/x86_64-w64-mingw32/sys-root/mingw
TARGET=x86_64-w64-mingw32
GDB_VERSION=7.9.1

cd $SRC_ROOT
pull mingw-w64

pushd gcc
git checkout -f $BRANCH_NAME
git pull
GCC_VERSION=$(cat gcc/BASE-VER)
INSTALL_ROOT=/havana/mingw-w64-$GCC_VERSION
REVISION=$(git show | grep -oP "($BRANCH_NAME|trunk)@\d+" | cut -f2 -d"@")
popd

rm -rf $INSTALL_ROOT

cd mingw-w64
rm -rf build-$GCC_VERSION; mkdir build-$GCC_VERSION; cd build-$GCC_VERSION
../configure --host=$TARGET --target=$TARGET \
             --prefix=$INSTALL_ROOT/x86_64-w64-mingw32 \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --with-tools=all --enable-sdk=all \
             --enable-secure-api --disable-lib32 --disable-shared
make -j$(nproc)
make install-strip

cd ../mingw-w64-libraries/winpthreads
rm -rf build-$GCC_VERSION; mkdir build-$GCC_VERSION; cd build-$GCC_VERSION
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT/x86_64-w64-mingw32 \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --disable-shared
make -j$(nproc)
make install-strip

mkdir -p $INSTALL_ROOT/mingw/include

cd $SRC_ROOT

rm -rf combined-$GCC_VERSION; mkdir combined-$GCC_VERSION; cd combined-$GCC_VERSION
ln -s ../gmp-* gmp
ln -s ../isl-* isl
ln -s ../mpfr-* mpfr
ln -s ../mpc-* mpc
ln -s ../gcc/* .
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
                      --disable-libvtv --with-arch=corei7 \
                      --with-tune=haswell --with-system-zlib --disable-nls \
                      --without-included-gettext --enable-linker-build-id \
                      --program-prefix=$TARGET-

make -j$(nproc)
make install

cd ..
cd gdb-$GDB_VERSION
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --disable-shared --disable-nls --program-prefix=$TARGET-
make -j$(nproc)
make install

cd $INSTALL_ROOT
cp $LOCAL_MINGW_ROOT/bin/{libexpat-1,zlib1}.dll bin
rm -rf mingw libexec/gcc/$TARGET/$GCC_VERSION/install-tools
rm bin/$TARGET-ld.bfd.exe bin/$TARGET-$TARGET-* $TARGET/bin/ld.bfd.exe 
$TARGET-strip bin/* libexec/gcc/$TARGET/$GCC_VERSION/* || true
cd ..

f=mingw-w64-$GCC_VERSION-r$REVISION
7z a -t7z -m0=lzma2 -mx=9 -mmt$(nproc) -ms=on $f.7z mingw-w64-$GCC_VERSION
scp $f.7z i10z.com:/havana/mingw-w64/$UPLOAD_DIRECTORY/
ssh i10z.com ln -sf /havana/mingw-w64/$UPLOAD_DIRECTORY/$f.7z /havana/mingw-w64/$UPLOAD_DIRECTORY/latest.7z
rm -r $f.7z
