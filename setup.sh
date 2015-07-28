#!/usr/bin/env zsh

cd ~
mkdir -p bin
pushd bin

ln -sf ../hacks/compilers/ccl.sh ccl
ln -sf ../hacks/compilers/vcpp.py vcpp
ln -sf ../hacks/utilities/ldd-windows
ln -sf ../hacks/utilities/mutt-open
ln -sf ../hacks/utilities/pb pbcopy
ln -sf ../hacks/utilities/pb pbpaste
ln -sf ../hacks/utilities/pull.py pull
ln -sf ../hacks/utilities/qc.py qc
ln -sf ../hacks/utilities/tmux-shell tmuxsh
ln -sf ../hacks/utilities/weather.py weather

popd
