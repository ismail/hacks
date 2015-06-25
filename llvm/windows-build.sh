#!/usr/bin/env zsh
set -uo pipefail

version=3.7
src=~/src/llvm
target=${1:-win32}
python_exe=C:/Python34/python.exe

function cleanup {
    cd $src
    mv -f .newbuild .oldbuild
    mv build.log ~/llvm-latest-build.log
}

trap cleanup EXIT

last_build_time=$(cat $src/.last_build_time 2> /dev/null)
current_time=$(date +%s)
time_diff=$(( (current_time - last_build_time) / (60*60) ))

if [ $time_diff -lt 6 ]; then
    echo "Last successful build was less than 6 hours ago, sleeping for 3 hours."
    sleep 3h
    exit 0
fi

cd $src
pull . tools/clang projects/compiler-rt | tee build.log

git log -1 --format="%h" > .newbuild
git --git-dir=./tools/clang/.git log -1 --format="%h" >> .newbuild
cmp -s .newbuild .oldbuild

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 1 hour" | tee -a build.log
    sleep 1h
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -f .last_build_time
rm -rf dist; mkdir dist; cd dist

export CC="$(cygpath -m =cl.exe)"
export CXX=$CC
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_ENABLE_TIMESTAMPS=ON -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_TARGETS_TO_BUILD="ARM;X86" -DPYTHON_EXECUTABLE=$python_exe -DLLVM_BUILD_TESTS=ON -DLLVM_LIT_TOOLS_DIR=C:/cygwin64/bin .. | tee -a ../build.log

ninja | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v test | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v tools/clang/test | tee -a ../build.log
ninja package | tee -a ../build.log

cd ..
date +%s > .last_build_time
rev="r$(git show | grep -oP "trunk@\d+" | cut -f2 -d"@")"
scp dist/LLVM-*.exe i10z.com:/havana/llvm/$target/LLVM-$version-$rev-$target.exe
ssh i10z.com ln -sf /havana/llvm/$target/LLVM-$version-$rev-$target.exe /havana/llvm/$target/latest.exe
