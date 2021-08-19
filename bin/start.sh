#!/bin/bash

ROOT='/home/pi/u.board'
FEH=`which feh`

C=`ls -l $ROOT/data | grep "^-" | wc -l `
[ $C -eq 0 ] && exit

export DISPLAY=:0
$FEH -qrYzFD5 --zoom fill $ROOT/data/ &
