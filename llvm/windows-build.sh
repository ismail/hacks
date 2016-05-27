#!/usr/bin/env zsh
set -uo pipefail

alias scp='rsync --archive --compress-level=3 \
           --copy-links --partial --inplace \
           --progress --rsh=ssh -r'

retry-if-fails () {
    [[ -o errexit ]] && errexit_set="1"; set +e
    retry=0
    timeout=10

    while [ $retry -le $timeout ]; do
        eval $@
        if [ $? -eq 0 ]; then
            break
        fi

        let "retry += 1"
        if [ $retry -ge $timeout ]; then
            echo "Timeout reached while trying to run command."
            break
        fi

        sleeptime=$(( 2**$retry ))
        echo "Command failed, sleeping $sleeptime seconds before retrying."
        sleep $sleeptime
    done

    [[ $errexit_set = "1" ]] && set -e
}

version=3.9
src=~/src/llvm
target=${1:-win64}
python_exe=C:/Python27/python.exe

function cleanup {
    cd $src
    [ -f .newbuild ] && mv .newbuild .oldbuild
    [ -f build.log ] && mv build.log ~/llvm-latest-build.log
}

trap cleanup EXIT

last_build_date=$(cat $src/.last_build_date 2> /dev/null)
current_date=$(date "+%Y%m%d")

if [ "x$current_date" = "x$last_build_date" ]; then
    wait_hours=$(( 23 - $(date +%H) ))
    echo "Sleeping for $wait_hours hours until next build."
    sleep ${wait_hours}h
fi

cd $src
pull . tools/{clang,clang/tools/extra,lld} projects/{compiler-rt,openmp} | tee build.log

git log -1 --format="%h" > .newbuild
git --git-dir=./tools/clang/.git log -1 --format="%h" >> .newbuild
cmp -s .newbuild .oldbuild

if [ $? = 0 ]; then
    echo "No new build. Sleeping for 1 hour." | tee -a build.log
    rm -f .last_build_date
    sleep 1h
    exit 0
fi

# We set here because cmp would exit early otherwise
set -e

rm -f .last_build_date
rm -rf dist; mkdir dist; cd dist

export CC="C:/Program Files/LLVM/bin/clang-cl.exe"
export CXX=$CC
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DLLVM_USE_CRT_RELEASE=MT -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD="ARM;X86" -DPYTHON_EXECUTABLE=$python_exe -DCLANG_DEFAULT_OPENMP_RUNTIME=libomp -DCMAKE_CL_SHOWINCLUDES_PREFIX="Note: including file: " -DLLVM_BUILD_TESTS=ON -DLLVM_LIT_TOOLS_DIR=C:/cygwin64/bin .. | tee -a ../build.log

ninja -j2 | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v test | tee -a ../build.log
$python_exe -u ./bin/llvm-lit.py -v tools/clang/test | tee -a ../build.log
ninja package | tee -a ../build.log

cd ..
echo $(date "+%Y%m%d") > .last_build_date
rev="r$(git show | grep -oP "trunk@\d+" | cut -f2 -d"@")"

osslsigncode sign -certs ~/csr/IsmailDonmez.pem \
                  -key ~/csr/IsmailDonmez.key -h sha256 \
                  -t http://time.certum.pl -n "LLVM" \
                  -i http://llvm.org -in dist/LLVM-*.exe \
                  -out dist/LLVM-signed.exe

retry-if-fails scp dist/LLVM-signed.exe i10z.com:/havana/llvm/$target/LLVM-$version-$rev-$target.exe
retry-if-fails ssh i10z.com ln -sf /havana/llvm/$target/LLVM-$version-$rev-$target.exe /havana/llvm/$target/latest.exe
cp dist/LLVM-signed.exe ~/Desktop
chmod +x ~/Desktop/LLVM-signed.exe
