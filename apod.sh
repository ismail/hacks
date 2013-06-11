#!/bin/sh

destination=/havana/Copy/Pictures/apod/
image_path=`curl -s -L http://apod.nasa.gov/apod/|grep -m 1 '<a href="image'|cut -f2 -d"\""`
image_name=`echo $image_path|cut -f3 -d"/"`

mkdir -p $destination
curl -s http://apod.nasa.gov/apod/$image_path -o $destination/$image_name

gsettings set org.gnome.desktop.background picture-uri file://$destination/$image_name
echo "Done."

