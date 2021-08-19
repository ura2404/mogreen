#!/bin/bash

ROOT='/home/pi/u.board'

rm -f /tmp/mogreen.hash
ls $ROOT/sdata | while read a; do
    echo `md5sum $ROOT/sdata/$a` >> /tmp/mogreen.hash
done
echo `md5sum /tmp/mogreen.hash | awk '{print $1}'` > $ROOT/hash/mogreen.hash
