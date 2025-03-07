#!/bin/bash

if [ -z "${MAIN_DIR}" ]; then
  export MAIN_DIR=${PWD}
fi

ENV_FILE=${MAIN_DIR}/.env
source ${ENV_FILE}

TAGET=${1}
if [ ${TAGET}x == "x" ]; then
  TAGET=${IMAGE_REGISTRY_NAME}:oc_cuda122_dev
fi

docker pull ${TAGET}

docker rm -f ${IMAGE_NAME}_oc_cuda122
cmd="docker run -d --name ${IMAGE_NAME}_oc_cuda122 \
            --privileged=true \
            --gpus all \
            -v /etc/localtime:/etc/localtime:ro \
            -v ${DATA_ROOT}:/root/data \
            -v ./.env:${ENV_PATH} \
            -v ./:/root/slines \
            -v /usr/local/cuda-12.2/bin:/usr/local/cuda/bin \
            -v /usr/local/cuda-12.2/include:/usr/local/cuda/include \
            -v /usr/local/cuda-12.2/lib64:/usr/local/cuda/lib64 \
            -v /root/data/cache/.cache:/root/.cache \
            -v /root/data/cache/.detectron2:/root/.detectron2 \
            -v /root/data/cache/.modelscope:/root/.modelscope \
            -v /root/data/cache/.paddlenlp:/root/.paddlenlp \
            -v /root/data/cache/.paddleocr:/root/.paddleocr \
            -v /root/data/cache/.inference:/root/.inference \
            -w /root \
            --env-file ${ENV_FILE} \
            -p ${WEB_START_PORT}:${WEB_START_PORT} \
            -p 8822:22 \
            ${TAGET} \
            /root/entrypoint.sh"
             
echo ${cmd}

( ${cmd} )
