#!/bin/sh
if [ "$1" == "--web"  ]; then
    web=1
    shift
fi
COMP=docker
DIST="Fedora"
[ -z "$1"  ] || COMP=$1
[ -z "$2"  ] || DIST=$2
if [ ! -z $web  ]; then
    bugs=`bugzilla query -c ${COMP} -p "${DIST}" -t MODIFIED --outputformat 'http://bugzilla.redhat.com/%{bug_id}'`
    echo ${bugs}
    x=0
    for i in ${bugs}; do 
        x=`expr $x + 1`
        google-chrome $i &
        echo $i
        sleep 1
        if [ $x -eq 50  ]; then
            x=0;
            read y
        fi
    done
else
    bugs=`bugzilla query -c ${COMP} -p "${DIST}" -t MODIFIED --outputformat '%{bug_id}'`
    echo ${bugs}
fi
