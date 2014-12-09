#!/bin/bash
#
# Originally found on http://cafbit.com/entry/terminal_window_size_detection_over

echo -en "\e[18t" # returns \e[8;??;??t
IFS='[;'
read -d t -s esc params
set -- $params
[ $# = 3 -a "$1" = 8 ] && shift
[ $# != 2 ] && echo error >&2 && exit 1
stty rows "$1" cols "$2"
