#!/bin/bash

mkdir -p /etc/docker

REGISTRY_MIRRORS=${1}
REGISTRY_ADDR=${2}

rm -rf /etc/docker/daemon.json
echo -e "{\n  \"registry-mirrors\": [\"${REGISTRY_MIRRORS}\"],\n  \"insecure-registries\": [\"${REGISTRY_ADDR}\"]\n}" > /etc/docker/daemon.json
cat /etc/docker/daemon.json

# systemctl daemon-reload && systemctl restart docker