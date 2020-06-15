#!/bin/bash

BN=`basename $0`
exec > /tmp/$BN.log 2>&1
echo `date` Starting 
FILE="arm-backup-`date +%a`.img.gz"
cat /dev/mmcblk0 | gzip | curl -v -N -T - --user "xoid:37Morkoy" "https://webdav.yandex.ru/BACKUP/$FILE"
#rm -f "/tmp/$FILE"



