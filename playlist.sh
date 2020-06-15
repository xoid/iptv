#!/bin/bash

URLS="https://webarmen.com/my/iptv/auto.nogrp.m3u \
      https://smarttvapp.ru/app/iptvfull.m3u \
      https://prosmarttv.ru/playlist/allplayer/gtv.m3u \
      https://webhalpme.ru/rif.m3u                     \
      http://dmitry-tv.my1.ru/iptv/d-tv.m3u \
      http://dmitry-tv.ru/iptv/Dmitry-tv.auto.m3u \
      http://iptvm3u.ru/one.m3u"

MAIN='Главные-каналы.m3u'
 ALL='Все-каналы.m3u'

cd /media
echo '#EXTM3U' > $MAIN.new
echo '#EXTM3U' > $ALL.new

for URL in $URLS
do
    echo URL $URL
    curl -L "$URL"|grep -v '#EXTM3U\|EXTGRP' >> $ALL.new
done
#exit 0
[ -s "$ALL.new" ] && mv -f $ALL.new $ALL

cat /root/server/header.html  > /root/server/index.html.new
/root/bin/playlist.pl $ALL   >> /root/server/index.html.new
cat /root/server/footer.html >> /root/server/index.html.new

mv /root/server/index.html.new  /root/server/index.html

#grep -i -A2 "СТС\|НТВ\|science\|discovery\|первый канал\|Cartoon" $ALL |grep -v '^--' >> $MAIN
# reread xupnpd
curl http://192.168.171.197:4044/scripts/scan.lua > /dev/null
mkdir -p /var/run/ssh /var/run/sshd

