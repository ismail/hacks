cd $1
ln -sf arm-linux-gnueabihf/libc/usr usr

cd lib
ln -sf ../arm-linux-gnueabihf/libc/lib/arm-linux-gnueabihf arm-linux-gnueabihf
ln -sf ../arm-linux-gnueabihf/libc/lib/arm-linux-gnueabihf/ld-2.19-2014.06.so ld-linux-armhf.so.3
