#!/usr/bin/env zsh
set -uo pipefail

version=3.7
src=~/src/llvm
target=${1:-win32}
python_exe=C:/Python34/python.exe

function cleanup {
    cd $src
    mv -f .newbuild .oldbuild
    cp build.log ~/build.log.$(date +%d.%m.%Y-%H.%M)
}

trap cleanup EXIT

cd $src

if [ -e .sleep ]; then
    echo "Build sleep requested. Sleeping for 10 minutes."
    sleep 10m
    exit 0
fi

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

export CC="$(cygpath -m =cl.exe)"
export CXX=$CC
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD="ARM;X86" -DPYTHON_EXECUTABLE=$python_exe -DLLVM_BUILD_TESTS=ON .. | tee -a ../build.log

ninja -j1 | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v test | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v tools/clang/test | tee -a ../build.log
ninja package | tee -a ../build.log
