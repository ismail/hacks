#!/bin/sh

font="Consolas"
font_size=13
geometry="117x49+114-53"

exec /usr/bin/xterm \
     +bc \
     +cm \
     -lc \
     +sb \
     -uc \
     -fa $font \
     -fd $font \
     -fs $font_size \
     -geometry $geometry \
     -ti vt340 \
     "$@"
