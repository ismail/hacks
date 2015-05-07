#!/bin/sh

font="Consolas"
font_size=13
geometry="127x59--6--9"

exec /usr/bin/xterm \
     +bc \
     +cm \
     +fbx \
     +sb \
     -uc \
     -wc \
     -u8 \
     -fa $font \
     -fd $font \
     -fs $font_size \
     -geometry $geometry \
     -e ~/bin/tmuxsh
