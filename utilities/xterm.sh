#!/bin/sh

geometry="117x49+114-53"

setsid /usr/bin/xterm \
       -geometry $geometry \
       "$@"
