#!/bin/bash

# 需要管理员权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行该脚本"
    exit 1
fi

# 要添加的条目
entries=(
    "192.168.1.5    registry.atoml.net"
    "192.168.1.5    midd.atoml.net"
)

# 逐条检查并追加
for entry in "${entries[@]}"; do
    if ! grep -qxF "$entry" /etc/hosts; then
        echo "$entry" >> /etc/hosts
        echo "已添加: $entry"
    else
        echo "已存在: $entry"
    fi
done

# 验证结果
echo -e "\n当前 /etc/hosts 内容:"
grep -A2 'atoml.net' /etc/hosts