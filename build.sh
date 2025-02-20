#!/bin/bash

# 获取完整的命令行
MAIN_DIR=$(dirname "$(readlink -f "$0")")
env_file="${MAIN_DIR}/.env"
echo ${env_file}

if [ -f ${env_file} ]; then
  source ${env_file}
fi

while getopts "bard:" opt; do
  case $opt in
    r)
        shift $((OPTIND-1))
        param1=$1

        if [ "$param1" = "build" ]; then
            CMD="docker-compose --env-file ${env_file} -f docker/docker-compose.yaml up --build"
        else
            CMD="docker-compose --env-file ${env_file} -f docker/docker-compose.yaml up $param1"
        fi
      ;;


    b)
        echo "构建基础镜像"
        CMD="docker build -t ${IMAGE_NAME} . \
                -f docker/dockerfile \
                --build-arg BASE_IMAGE=${BASE_IMAGE} \
                --build-arg RUNNER_IMAGE=${RUNNER_IMAGE}
                "
      ;;

    a)
        echo "构建应用镜像"

        # 提示用户输入用户名
        echo "GIT用户名:"
        read username

        # 提示用户输入密码
        echo "GIT密码:"
        # -s 选项使得输入时不回显
        read -s password

        CMD="docker build -t ${IMAGE_NAME}_app . \
                -f docker/dockerfile_app \
                --build-arg RUNNER_IMAGE=${IMAGE_NAME} \
                --build-arg GIT_USERNAME=${username} \
                --build-arg GIT_PASSWORD=${password}"
      ;;

    # r)
    #     echo "构建应用容器"
    #     docker rm -f ${CONTAINER_NAME}_app

    #     # 构建容器
    #     CMD="docker run -d --name ${CONTAINER_NAME}_app \
    #                 -v /etc/localtime:/etc/localtime:ro \
    #                 -v /root/data/:/root/data \
    #                 -w /root/app \
    #                 -p ${WEB_START_PORT}:80 \
    #                 -p ${SANDBOX_START_PORT}:8194 \
    #                 -e API_KEY=${SANDBOX_API_KEY:-dify-sandbox} \
    #                 -e GIN_MODE=${SANDBOX_GIN_MODE:-release} \
    #                 -e WORKER_TIMEOUT=${SANDBOX_WORKER_TIMEOUT:-15} \
    #                 -e ENABLE_NETWORK=${SANDBOX_ENABLE_NETWORK:-true} \
    #                 -e HTTP_PROXY=${SANDBOX_HTTP_PROXY:-http://ssrf_proxy:3128} \
    #                 -e HTTPS_PROXY=${SANDBOX_HTTPS_PROXY:-http://ssrf_proxy:3128} \
    #                 -e SANDBOX_PORT=${SANDBOX_PORT:-8194} \
    #                 ${IMAGE_NAME} \
    #                 "
    #                 # tail -f /dev/null
    #                 # --gpus all \
    #     ;;

    \?)
      echo "无效的选项: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

echo ${CMD}
( ${CMD} )