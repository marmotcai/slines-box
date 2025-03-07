#!/bin/bash

if [ -z "${MAIN_DIR}" ]; then
  export MAIN_DIR=${PWD}
fi

if [ -z "${DOCKER_DIR}" ]; then
  export DOCKER_DIR=${MAIN_DIR}/docker
fi

run_cmd="docker-compose -f $DOCKER_DIR/docker-compose-base.yml --project-directory ./ up -d ollama"
echo ${run_cmd}
( ${run_cmd} )