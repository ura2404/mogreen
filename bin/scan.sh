#!/bin/bash

ROOT='/home/pi/u.board'

IP=`which ip`
NMAP=`which nmap`
FEH=`which feh`

MYID=`cat /boot/u.board/config.json | grep '"id"' | awk -F: '{ gsub(/ |,|\"/,""); print $2}'`

function restart(){
    echo '--->restart'

    ps aux | grep feh | grep -v 'grep' | awk '{print $2}' | while read a; do
        kill $a
    done

    export DISPLAY=:0
    $FEH -qrYzFD120 --zoom fill $ROOT/data/ &
}

function get(){
    echo '4-->'$1
    #rm -Rf /tmp/mogreen-$MYID
    #mkdir -p /tmp/mogreen-$MYID

    rm -f $ROOT/data/*
    wget ftp://pi:pi@$1/u.board/sdata/$MYID*.png -o /dev/null -P $ROOT/data/

    #C=`ls -l $ROOT/data/ | grep "^-" | wc -l `
    #[ $C -eq 0 ] && exit

    #rm -f $ROOT/data/*
    #mv /tmp/mogreen-$MYID/* $ROOT/data/

    restart
}

function check(){
    echo '3->>'$1
    rm -f /tmp/mogreen.hash
    wget ftp://pi:pi@$1/u.board/hash/mogreen.hash -o /dev/null -O /tmp/mogreen.hash

    [ ! -f  /tmp/mogreen.hash ] && exit
    [ ! -f  /tmp/mogreen-$MYID.hash ] && cp /tmp/mogreen.hash /tmp/mogreen-$MYID.hash

    H1=`md5sum /tmp/mogreen.hash | awk '{print $1}'`
    H2=`md5sum /tmp/mogreen-$MYID.hash | awk '{print $1}'`

    [  "$H1" == "$H2" ] && exit
    cp /tmp/mogreen.hash /tmp/mogreen-$MYID.hash

    get $1
}

function scan(){
    #$NMAP -p 21 --open $1 
    $NMAP -p 21 --open $1 | grep 'report' | awk '{print $5}' | while read a; do
        echo '2->>'$a
        check $a
    done
}

PID=`ps aux | grep feh | grep -v 'grep' | awk '{print $2}'`
[ -z $PID ] && restart

$IP addr | grep 'inet' | grep -v 'inet6' | grep -v 'host lo' | awk '{print $2}' | grep '/' | while read a; do
    echo '1->>'$a
    scan $a
done
