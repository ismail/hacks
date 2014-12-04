@echo OFF

vcvars32.bat
svn up . tools/clang tools/clang/tools/extra projects/compiler-rt

rm -rf dist
mkdir dist
cd dist

cmake -G "Ninja" -DLLVM_ENABLE_TIMESTAMPS=OFF -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_BUILD_TYPE=Release ..
ninja
ninja package
