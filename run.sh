#!/bin/bash

# 定义帮助信息函数
print_help() {
  echo "使用方法: $0 [-a] [-b [build|push]]"
  echo "选项："
  echo "  -a    构建应用镜像"
  echo "  -b    运行容器"
  echo "        - build: 构建并运行容器"
  echo "        - push: 推送容器"
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

while getopts "ab:h" opt; do
  case $opt in
  b)
    # 使用逗号分隔多个参数
    IFS=',' read -ra params <<< "$OPTARG"
    param1=${params[0]}
    param2=${params[1]}
    param3=${params[2]}

    if [ "$param1" = "push" ]; then
      # 然后使用 xargs 批量推送
      docker images --format "{{.Repository}}:{{.Tag}}" | grep "192.168.193.7:20050" | xargs -n1 docker push
      exit 0
    elif [ "$param1" = "build" ]; then
      CMD="docker-compose --env-file ${env_file} -f docker/docker-compose.yaml --project-directory ${MAIN_DIR} up --build"
    elif [ "$param1" = "run" ]; then
      CMD="docker-compose --env-file ${env_file} -f docker/docker-compose.yaml up $param2"
    fi
    
    echo ${CMD}
    ( ${CMD} )
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