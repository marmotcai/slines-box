#!/bin/bash

# 定义帮助信息函数
print_help() {
  echo "使用方法: $0 [-a] [-b [build|push]]"
  echo "选项："
  echo "  -b    运行容器"
  echo "        - build: 构建并运行容器"
  echo "        - push: 推送容器"
  echo "        - up: 运行容器"
  echo "  -t    安装工具"
  echo "        - docker-compose: 安装 docker-compose"
  exit 1
}

# 获取完整的命令行
MAIN_DIR=$(dirname "$(readlink -f "$0")")
env_file="${MAIN_DIR}/docker/.env"
# echo ${env_file}

if [ -f ${env_file} ]; then
  source ${env_file}
fi

# 如果没有参数，显示帮助信息
if [ $# -eq 0 ]; then
  print_help
fi

while getopts "b:t:h" opt; do
  case $opt in
  b)
    action="$OPTARG"
    
    case "$action" in
      push)
        # 使用 while 循环代替 xargs
        CMD='docker images --format "{{.Repository}}:{{.Tag}}" | grep "${IMAGE_REGISTRY_NAME}" | while read img; do docker push "$img"; done'
        ;;

      build|up|down)
        shift $((OPTIND-1))
        service="${1:-}"  # 允许服务名为空
        if [ -z "$service" ]; then
            service=${START_SERVICE_LIST}
        fi

        # 动态构建命令
        base_cmd="docker-compose --env-file ${env_file} -f docker/docker-compose.yaml"
        [ "$action" = "build" ] && base_cmd+=" --project-directory ${MAIN_DIR} up --build"
        [ "$action" = "up" ] && base_cmd+=" up -d"
        [ "$action" = "down" ] && base_cmd+=" down"

        # 仅在服务名存在时追加
        [ -n "$service" ] && base_cmd+=" $service"
        CMD="$base_cmd"
        ;;

      *)
        echo "未知的操作: $action"
        print_help
        ;;
    esac
    ;;

  t)
    # 使用逗号分隔多个参数
    IFS=',' read -ra params <<< "$OPTARG"
    param1=${params[0]}
    param2=${params[1]}
    param3=${params[2]}

    if [ "$param1" = "docker-compose" ]; then
      export HTTPS_PROXY=192.168.1.7:30090
      curl -L https://github.com/docker/compose/releases/download/v2.29.5/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose    
    fi

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

if [ -n "$CMD" ]; then
  echo "执行命令: $CMD"
  eval "$CMD"
fi