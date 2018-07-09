#!/usr/bin/env zsh

curdir=$(pwd)
cd $HOME

mkdir -p bin
pushd bin

ln -sf $curdir/utilities/ldd-windows
ln -sf $curdir/utilities/mutt-open
ln -sf $curdir/utilities/pb pbcopy
ln -sf $curdir/utilities/pb pbpaste
ln -sf $curdir/utilities/pull.py pull
ln -sf $curdir/utilities/tmux-shell tmuxsh

popd
