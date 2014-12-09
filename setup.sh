#!/bin/zsh

cd ~
mkdir -p bin
pushd bin

ln -sf ../hacks/ccl.sh ccl
ln -sf ../hacks/mutt-open
ln -sf ../hacks/pull.py pull
ln -sf ../hacks/qc.py qc
ln -sf ../hacks/vcpp.py vcpp
ln -sf ../hacks/weather.py weather

popd
