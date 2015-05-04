#!/bin/sh

echo ':CLR:M::MZ::/usr/bin/mono:' | sudo tee -a /proc/sys/fs/binfmt_misc/register
