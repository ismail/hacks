#!/bin/sh
set -euo pipefail

svn up . tools/clang tools/clang/tools/extra

rm -rf dist
mkdir dist
cd dist

export PATH="/cygdrive/c/Program\ Files/SlikSvn/bin":$PATH
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_TESTS=ON -DLLVM_LIT_ARGS="-s" -DLLVM_LIT_TOOLS_DIR='C:\bin' ..

ninja
ninja check-all
ninja package
