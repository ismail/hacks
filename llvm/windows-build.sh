#!/bin/sh
set -uo pipefail
version=3.6.0

function cleanup {
    mv -f .newbuild .oldbuild
}

trap cleanup EXIT

pull . tools/clang | tee build.log

git log -1 --format="%h" > .newbuild
git --git-dir=./tools/clang/.git log -1 --format="%h" >> .newbuild
cmp -s .newbuild .oldbuild

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 10 minutes."
    sleep 10m
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -rf dist; mkdir dist; cd dist

cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD="ARM;X86" -DPYTHON_EXECUTABLE=C:/Python27/python.exe -DLLVM_BUILD_TESTS=ON .. | tee -a ../build.log

ninja | tee -a ../build.log
ninja check-all | tee -a ../build.log
ninja package | tee -a ../build.log

cd ..
rev=`git log -1 --format="%h"`
scp dist/LLVM-*.exe i10z.com:/havana/llvm/win32/LLVM-$version-$rev-win32.exe
scp build.log i10z.com:/havana/llvm/win32/latest.log
ssh i10z.com ln -sf /havana/llvm/win32/LLVM-$version-$rev-win32.exe /havana/llvm/win32/latest.exe

