#!/bin/sh

blob=':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
binfmt="/proc/sys/fs/binfmt_misc"

if [ -e $binfmt/arm ]; then
    echo -1 | tee $binfmt/arm &> /dev/null
fi

if [ x$1 = x"reset" ]; then
    echo "$blob:/usr/bin/qemu-arm-binfmt:P" | tee $binfmt/register > /dev/null
else
    echo "$blob:/home/ismail/bin/arm-emu:" | tee $binfmt/register > /dev/null
fi
