#!/bin/bash

docker_name=${1}

if [ ! "${docker_name}" ]; then
    docker ps -a | grep "Exited" | awk '{print $1 }' | xargs docker rm -f

    docker ps -a | grep "Created" | awk '{print $1 }' | xargs docker rm -f

    docker images | grep none | awk  '{print $3 }' | xargs docker rmi -f

    # sudo lsof -i :8000 | awk '{print $2 }' | xargs kill -9

    docker system prune -a -f

    exit 0
fi

docker ps -a | grep ${docker_name} | awk '{print $1 }' | xargs docker rm -f

docker images | grep ${docker_name} | awk '{print $3}' | xargs docker rmi -f
