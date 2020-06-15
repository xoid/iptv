#!/bin/bash

CHANNEL=$1
[ -z "$CHANNEL" ] && { echo "No channnel name" >&2; exit 6; }
[ "$CHANNEL" == "playlist" ] && { /root/bin/playlist.sh; exit 0; }

URL=`grep -i -A4 "$CHANNEL" /root/all.m3u|grep -v '^#'| head -1`
echo URL $URL
echo $URL     > /etc/now_playing.url
echo $CHANNEL > /root/server/now_playing.channel

killall mpv
killall -0 mpv.sh || nohup /root/mpv.sh &


