#!/bin/sh

if [[ $1 = "-r" ]]; then
    sudo cpupower frequency-set -g powersave
else
    sudo cpupower frequency-set -g performance
fi
