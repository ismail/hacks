#!/usr/bin/env zsh
set -uo pipefail

version=3.7
src=~/code/llvm
target=${1:-win32}
python_exe=C:/Python27/python.exe

cd $src

function cleanup {
    cd $src
    mv -f .newbuild .oldbuild
    cp build.log ~/build.log.$(date +%d.%m.%Y-%H.%M)
}

trap cleanup EXIT

pull . tools/clang | tee build.log

git log -1 --format="%h" > .newbuild
git --git-dir=./tools/clang/.git log -1 --format="%h" >> .newbuild
cmp -s .newbuild .oldbuild

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 10 minutes." | tee -a build.log
    sleep 10m
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -rf dist; mkdir dist; cd dist

export CC="$(cygpath -m "$(whence cl.exe)")"
export CXX=$CC
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD="ARM;X86" -DPYTHON_EXECUTABLE=$python_exe -DLLVM_BUILD_TESTS=ON .. | tee -a ../build.log

ninja -j1 | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v test | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v tools/clang/test | tee -a ../build.log
ninja package | tee -a ../build.log

cd ..
rev=$(git log -1 --format="%h")
scp dist/LLVM-*.exe i10z.com:/havana/llvm/$target/LLVM-$version-$rev-$target.exe
scp build.log i10z.com:/havana/llvm/$target/latest.log
ssh i10z.com ln -sf /havana/llvm/$target/LLVM-$version-$rev-$target.exe /havana/llvm/$target/latest.exe

# Bintray upload
curl -T dist/LLVM-*-$target.exe -uismail:$(cat ~/.bintray) -H X-Bintray-Package:llvm-$target -H X-Bintray-Version:$version-$rev -H X-Bintray-Publish:1 https://api.bintray.com/content/ismail/llvm/LLVM-$version-$rev-$target.exe
