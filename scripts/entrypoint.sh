#!/bin/bash

echo "start runner service."

export MAIN_DIR=${PWD}

source "${MAIN_DIR}/global.env"

export LD_LIBRARY_PATH=${PWD}/runner/utils/swofdlib:${LD_LIBRARY_PATH}

if [ ! -z ${DEBUG} ] && [ ${DEBUG} == "true" ]; then
  echo "start debug mode."
  /usr/sbin/sshd -D
  tail -f /dev/null
fi

SERVICE_MODE=${1}
if [ -z ${SERVICE_MODE} ]; then
  SERVICE_MODE="server"
fi

SERVICE_PORT=${2}
if [ -z ${SERVICE_PORT} ]; then
  SERVICE_PORT=${DEFAULT_APP_PORT}
fi

DATA=${3}
if [ -z ${DATA} ]; then
  DATA=${DATA_ROOT}
fi

export PIPELINE_YAML_PATH=${DEFAULT_PIPELINE_YAML_PATH}
export PIPELINE_NAME=${DEFAULT_PIPELINE_NAME}

CMD="python main.py -m ${SERVICE_MODE} -h 0.0.0.0 -p ${SERVICE_PORT} -d ${DATA}"
( ${CMD} )
