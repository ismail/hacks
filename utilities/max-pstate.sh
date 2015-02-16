#!/usr/bin/env zsh

echo performance | sudo tee -a /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor &> /dev/null

