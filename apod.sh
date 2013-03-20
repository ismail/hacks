#!/bin/sh

mkdir -p /havana/apod

image_path=`curl -s -L http://apod.nasa.gov/apod/|grep '<a href="image'|cut -f2 -d"\""`
image_name=`echo $image_path|cut -f3 -d"/"`

curl -s http://apod.nasa.gov/apod/$image_path -o /havana/Dropbox/Pictures/apod/$image_name

gsettings set org.gnome.desktop.background picture-uri file:///havana/Dropbox/Pictures/apod/$image_name
echo "Done."

