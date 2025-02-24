#!/bin/bash

# 定义帮助信息函数
print_help() {
  echo "使用方法: $0 [-b] [-a] [-r [build|<container_name>]]"
  echo "选项："
  echo "  -b    构建基础镜像"
  echo "  -a    构建应用镜像"
  echo "  -r    运行容器"
  echo "        - build: 构建并运行容器"
  echo "        - <container_name>: 运行指定容器"
  exit 1
}

# 获取完整的命令行
MAIN_DIR=$(dirname "$(readlink -f "$0")")
env_file="${MAIN_DIR}/.env"
echo ${env_file}

if [ -f ${env_file} ]; then
  source ${env_file}
fi

# 如果没有参数，显示帮助信息
if [ $# -eq 0 ]; then
  print_help
fi

while getopts "bar:h" opt; do
  case $opt in
  r)
    param1=$OPTARG
    echo ${param1}

    if [ -z "$param1" ]; then
      echo "错误: -r 选项需要参数" >&2
      print_help
    fi

    if [ "$param1" = "build" ]; then
      CMD="docker-compose --env-file ${env_file} -f docker/docker-compose.yaml --project-directory ${MAIN_DIR} up --build"
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
    echo "GIT用户名:"
    read username
    echo "GIT密码:"
    read -s password

    CMD="docker build -t ${IMAGE_NAME}_app . \
        -f docker/dockerfile_app \
        --build-arg RUNNER_IMAGE=${IMAGE_NAME} \
        --build-arg GIT_USERNAME=${username} \
        --build-arg GIT_PASSWORD=${password}"
    ;;

  h)
    print_help
    ;;

  \?)
    echo "错误: 无效的选项 -$OPTARG" >&2
    print_help
    ;;
  esac
done

# 检查是否设置了CMD
if [ -z "$CMD" ]; then
  echo "错误: 无效的参数组合" >&2
  print_help
fi

echo ${CMD}
( ${CMD} )