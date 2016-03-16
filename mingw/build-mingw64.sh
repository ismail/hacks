#!/usr/bin/env zsh
set -euo pipefail

alias scp='rsync --archive --compress-level=3 \
           --copy-links --partial --inplace \
           --progress --rsh=ssh -r'

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

SRC_ROOT=/ssd/mingw-w64-build
LOCAL_MINGW_ROOT=/usr/x86_64-w64-mingw32/sys-root/mingw
TARGET=x86_64-w64-mingw32
BINUTILS_VERSION=2.26

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
             --enable-sdk=all --enable-secure-api --disable-lib32 \
             --disable-shared
make -j4
make install-strip

cd ../mingw-w64-libraries/winpthreads
rm -rf build-$GCC_VERSION; mkdir build-$GCC_VERSION; cd build-$GCC_VERSION
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT/x86_64-w64-mingw32 \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --disable-shared
make -j4
make install-strip

mkdir -p $INSTALL_ROOT/mingw/include

cd $SRC_ROOT

rm -rf combined-$GCC_VERSION; mkdir combined-$GCC_VERSION; cd combined-$GCC_VERSION
ln -s ../gmp-* gmp
ln -s ../isl-* isl
ln -s ../mpfr-* mpfr
ln -s ../mpc-* mpc
ln -s ../gcc/* .
cd ..

rm -rf build-$GCC_VERSION; mkdir build-$GCC_VERSION; cd build-$GCC_VERSION

../combined-$GCC_VERSION/configure --build=x86_64-suse-linux-gnu --host=$TARGET --target=$TARGET \
                      --prefix=$INSTALL_ROOT --with-sysroot=$INSTALL_ROOT \
                      --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
                      --disable-gcov-tool --disable-multilib --disable-nls \
                      --disable-win32-registry --enable-checking=release \
                      --enable-languages=c,c++,fortran --enable-fully-dynamic-string \
                      --enable-libgomp --enable-threads=posix --disable-werror \
                      --disable-libvtv --with-tune=core-avx2 \
                      --disable-nls --enable-linker-build-id --program-prefix=$TARGET-

make CFLAGS_FOR_TARGET="-Wno-error" -j2
make install

cd $SRC_ROOT/binutils-$BINUTILS_VERSION
rm -rf build; mkdir build; cd build
../configure --host=$TARGET --target=$TARGET --prefix=$INSTALL_ROOT \
             --libdir=$INSTALL_ROOT/lib --libexecdir=$INSTALL_ROOT/libexec \
             --disable-shared --disable-nls --program-prefix=$TARGET- \
             --with-sysroot
make -j4
make install


cd $INSTALL_ROOT
rm -rf mingw libexec/gcc/$TARGET/$GCC_VERSION/install-tools
rm bin/$TARGET-ld.bfd.exe bin/$TARGET-$TARGET-* $TARGET/bin/ld.bfd.exe 
$TARGET-strip bin/* libexec/gcc/$TARGET/$GCC_VERSION/* || true
cd ..

f=mingw-w64-$GCC_VERSION-r$REVISION
7z a -t7z -m0=lzma2 -mx=9 -mmt$(nproc) -ms=on $f.7z mingw-w64-$GCC_VERSION
scp $f.7z i10z.com:/havana/mingw-w64/$UPLOAD_DIRECTORY/
ssh i10z.com ln -sf /havana/mingw-w64/$UPLOAD_DIRECTORY/$f.7z /havana/mingw-w64/$UPLOAD_DIRECTORY/latest.7z
rm $f.7z
