#!/bin/bash

cd /media
URL=`grep -A4 НТВ /root/main.m3u|grep -v '^#'| head -1`
echo URL $URL
#exit 6
killall mpv
while true
do
   /root/mpv.sh "$URL"
done
