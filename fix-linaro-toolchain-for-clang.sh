LD_VERSION=2.20-2014.11-1-git

cd $1/lib
ln -sf ld-"$LD_VERSION".so ld-linux-armhf.so.3
