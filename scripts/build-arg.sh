#!/bin/bash

args_file=${1}

if [ -z ${args_file} ]; then
    args_file=.args
fi

ARGS=""
while read line
do
    if [ -z $line ]; then
        continue
    fi
    ARGS=${ARGS}" --build-arg $line"
done < ${args_file}