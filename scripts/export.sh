#!/bin/bash

envfile=${1}

if [ -z ${envfile} ]; then
    envfile=global.env
fi

while read line
do
    if [ -z $line ]; then
        continue
    fi
    export $line
done < ${envfile}