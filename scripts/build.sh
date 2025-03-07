
#!/bin/bash

########################################################################

source ${SCRIPTS_DIR}/getos.sh
bash ${SCRIPTS_DIR}/color.sh blue "当前系统：${OS}"

export SWBUILDER_CMD="swbuilder"

TAGET=${1}
PROPATH=${2}
WANT_TO_DO=${3}

if [ ${PROPATH}x == "x" ]; then
  PROPATH="."
fi

########################################################################

function build_image(){
  build_cmd="${SWBUILDER_CMD} ${TAGET} -f ${PROPATH}/slines.yml"
  echo ${build_cmd}
  ( ${build_cmd} )
}

function push_image(){
  tag_cmd="docker tag ${IMAGE_NAME}:${TAGET} ${IMAGE_REGISTRY_NAME}:${TAGET}"
  echo ${tag_cmd}
  push_cmd="docker push ${IMAGE_REGISTRY_NAME}:${TAGET}"
  echo ${push_cmd}
  ( ${tag_cmd} && ${push_cmd} )
}

function run_image(){
  DOCKERCOMPOSE_PATH="${DOCKER_DIR}/docker-compose.yml"
  if [ -f ${DOCKERCOMPOSE_PATH} ]; then
    run_cmd="docker-compose -f  ${DOCKERCOMPOSE_PATH} --project-directory ${PROPATH} up -d ${TAGET}"
    bash ${SCRIPTS_DIR}/color.sh blue ${run_cmd}
    ${run_cmd}
  fi
}

########################################################################

  if [ ${WANT_TO_DO}x == "x" ]; then
    source ${SCRIPTS_DIR}/color.sh green "请选择(build: 构建镜像, push: 推送镜像, run: 运行实例, othen: 退出):"
    read WANT_TO_DO
  fi

  case $WANT_TO_DO in
      #########################################################################
      build) # 构建镜像
        build_image
      ;;

      #########################################################################
      push) # 推送镜像
        push_image
      ;;

      run) # 运行实例
        run_image
      ;;

      *)
        exit 0
      ;;
      esac