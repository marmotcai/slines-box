#!/bin/bash
# filepath: rename_images.sh

# 检查参数数量
if [ $# -ne 2 ]; then
    echo "Usage: $0 <old_registry> <new_registry>"
    echo "Example: $0 registry.atoml.net:20050 new.registry:5000"
    exit 1
fi

OLD_REGISTRY=$1
NEW_REGISTRY=$2

# 获取所有包含旧地址的镜像
for img in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "$OLD_REGISTRY"); do
    # 构建新的镜像名称
    new_name=$(echo $img | sed "s|$OLD_REGISTRY|$NEW_REGISTRY|g")
    
    # 打印要执行的操作
    echo "Retagging $img -> $new_name"
    
    # 标记新镜像
    docker tag $img $new_name
    
    # 删除旧镜像
    docker rmi $img
done