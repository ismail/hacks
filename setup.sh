#!/usr/bin/env zsh

curdir=$(dirname "$(realpath "$0")")
cd "$HOME"

mkdir -p bin
pushd bin

ln -sf "$curdir/pull.py" pull
ln -sf "$curdir/tmux-shell" tmuxsh

popd