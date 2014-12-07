#!/bin/sh
set -euo pipefail

svn up . tools/clang tools/clang/tools/extra

rm -rf dist
mkdir dist
cd dist

cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_TESTS=ON ..

ninja
ninja check-all || true
ninja package
