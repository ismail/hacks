#!/usr/bin/env zsh

curdir=$(pwd)
cd $HOME

mkdir -p bin
pushd bin

ln -sf $curdir/mutt-open
ln -sf $curdir/pb pbcopy
ln -sf $curdir/pb pbpaste
ln -sf $curdir/pull.py pull
ln -sf $curdir/tmux-shell tmuxsh

popd
