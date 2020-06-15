#!/bin/bash

cd /media
URL=`grep -A4 НТВ /root/main.m3u|grep -v '^#'| head -1`
echo URL $URL
echo $URL > /root/now_playing.url

