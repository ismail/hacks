#!/usr/bin/env zsh
set -uo pipefail

alias scp='rsync --archive --compress-level=3 \
           --copy-links --partial --inplace \
           --progress --rsh=ssh -r'

retry-if-fails () {
    set +e
    retry=1 
    timeout=10 
    while [ $retry -le $timeout ]
    do
        eval $@
        if [ $? -eq 0 ]
        then
            break
        fi
        sleeptime=$(( 2**$retry )) 
        echo "Command failed, sleeping $sleeptime seconds before retrying."
        sleep $sleeptime
        let "retry += 1"
    done
    if [ $retry -ge $timeout ]
    then
        echo "Timeout reached while trying to run command."
    fi
}

version=3.8
src=~/src/llvm
target=${1:-win64}
wait_hours=24
python_exe=C:/Python27/python.exe

function cleanup {
    cd $src
    [ -f .newbuild ] && mv .newbuild .oldbuild
    [ -f build.log ] && mv build.log ~/llvm-latest-build.log
}

trap cleanup EXIT

last_build_time=$(cat $src/.last_build_time 2> /dev/null)
current_time=$(date +%s)
time_diff=$(( (current_time - last_build_time) / (60*60) ))

if [ $time_diff -lt $wait_hours ]; then
    extra_wait_time=$(( wait_hours - time_diff ))
    echo "Sleeping for $extra_wait_time hours until next build."
    sleep ${extra_wait_time}h
    exit 0
fi

cd $src
pull . tools/{clang,clang/tools/extra,lld} projects/{compiler-rt,openmp} | tee build.log
# XXX: HACK for VS2015
rm -f test/DebugInfo/PDB/DIA/pdbdump-symbol-format.test

git log -1 --format="%h" > .newbuild
git --git-dir=./tools/clang/.git log -1 --format="%h" >> .newbuild
cmp -s .newbuild .oldbuild

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 1 hour." | tee -a build.log
    sleep 1h
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -f .last_build_time
rm -rf dist; mkdir dist; cd dist
start_time=$(date +%s)

export CC="$(cygpath -m =cl.exe)"
export CXX=$CC
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_ENABLE_TIMESTAMPS=ON -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_TARGETS_TO_BUILD="ARM;X86" -DPYTHON_EXECUTABLE=$python_exe -DCLANG_DEFAULT_OPENMP_RUNTIME=libomp -DLLVM_BUILD_TESTS=ON -DLLVM_LIT_TOOLS_DIR=C:/cygwin64/bin .. | tee -a ../build.log

ninja -j2 | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v test | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v tools/clang/test | tee -a ../build.log
ninja package | tee -a ../build.log

cd ..
echo $start_time > .last_build_time
rev="r$(git show | grep -oP "trunk@\d+" | cut -f2 -d"@")"

cp dist/LLVM-*.exe $USERPROFILE/Desktop/
retry-if-fails scp dist/LLVM-*.exe i10z.com:/havana/llvm/$target/LLVM-$version-$rev-$target.exe
retry-if-fails ssh i10z.com ln -sf /havana/llvm/$target/LLVM-$version-$rev-$target.exe /havana/llvm/$target/latest.exe
