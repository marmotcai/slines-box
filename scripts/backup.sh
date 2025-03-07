#!/bin/bash

source /root/slines-builtin/docker/.env_dev_linux

# 定义要备份的目录和备份存储目录
SOURCE_DIR="/root/data/${MAIN_VERSION}"
echo "source dir: ${SOURCE_DIR}"

BACKUP_DIR="/root/backup"

BACKUP_DIR=${BACKUP_DIR}/$(date +%Y%m)
echo "backup dir: ${BACKUP_DIR}"
mkdir -p ${BACKUP_DIR}

# 创建备份文件名
BACKUP_FILE="${BACKUP_DIR}/$(date +%m-%d).tar.gz"
echo "backup file: ${BACKUP_FILE}"

# 打包压缩目录
tar -czf ${BACKUP_FILE} -C ${SOURCE_DIR} .

# 打印备份完成消息
echo "Backup completed: ${BACKUP_FILE}"