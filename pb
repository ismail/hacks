#!/bin/sh
set -euo pipefail

case $0 in
    *pbcopy )
        if [ -e /dev/clipboard ]; then
            cat > /dev/clipboard
        else
            xclip -selection clipboard
        fi
        ;;
    *pbpaste )
        if [ -e /dev/clipboard ]; then
            cat /dev/clipboard
        else
            xclip -selection clipboard -o
        fi
        ;;
    * )
        echo "Unknown alias $0"
        ;;
esac