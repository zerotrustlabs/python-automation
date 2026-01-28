#!/bin/bash
set -e

echo $0

echo $1

if [ "$1" ] && [ "$2" ]; then
    docker run -it --name $1 $2 sh;
else
    if [ ! "$2" ];then
        docker run -it --name $1 nginx;
    fi

fi
# echo $(ls -a)
# echo $?
# echo $@