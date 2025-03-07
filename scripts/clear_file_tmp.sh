#!/bin/bash

CUR_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd);
MAIN_DIR=$(dirname "${CUR_DIR}" )

CLEAR_DIR=${1}
if [ -z "${CLEAR_DIR}" ]; then
  CLEAR_DIR=$MAIN_DIR
fi

echo "clear dir: ${CLEAR_DIR}"

if [ -d ${CLEAR_DIR} ]; then
  find ${CLEAR_DIR} -name migrations | xargs rm  -rf
  find ${CLEAR_DIR} -name __pycache__ | xargs rm  -rf
  find ${CLEAR_DIR} -name *.sqlite3 | xargs rm  -rf
  find ${CLEAR_DIR} -name *.db | xargs rm  -rf  
  find ${CLEAR_DIR} -name *.initialize | xargs rm  -rf
  find ${CLEAR_DIR} -name *.DS_Store | xargs rm  -rf
fi

docker system prune