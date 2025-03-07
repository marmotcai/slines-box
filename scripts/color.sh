#!/bin/bash

BLACK='\033[1;31m'        # 黑
RED='\033[1;31m'        # 红
GREEN='\033[1;32m'      # 绿
YELOW='\033[1;33m'      # 黄
BLUE='\033[1;34m'       # 蓝
PINK='\033[1;35m'       # 粉红
CYAN='\033[1;36m'       # 青蓝
WHITE='\033[1;37m'       # 白
RES='\033[0m'           # 清除颜色

SETCOLOR_BLACK="echo -en ${BLACK}"
SETCOLOR_RED="echo -en ${RED}"
SETCOLOR_GREEN="echo -en ${GREEN}"
SETCOLOR_YELOW="echo -en ${YELOW}"
SETCOLOR_BLUE="echo -en ${BLUE}"
SETCOLOR_PINK="echo -en ${PINK}"
SETCOLOR_CYAN="echo -en ${CYAN}"
SETCOLOR_WHITE="echo -en ${WHITE}"
SETCOLOR_RES="echo -en ${RES}"

COLOR=SETCOLOR_RES
case ${1} in
black)
  COLOR=$SETCOLOR_BLACK
;;
red)
  COLOR=$SETCOLOR_RED
;;
green)
  COLOR=$SETCOLOR_GREEN    
;;
yelow)
  COLOR=$SETCOLOR_YELOW    
;;
blue)
  COLOR=$SETCOLOR_BLUE    
;;
pink)
  COLOR=$SETCOLOR_PINK    
;;
cyan)
  COLOR=$SETCOLOR_CYAN
;;
white)
  COLOR=$SETCOLOR_WHITE    
;;
esac

${COLOR}
body=$*
echo ${body/${1}/}
${SETCOLOR_RES}
