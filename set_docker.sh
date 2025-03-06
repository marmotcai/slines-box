#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Create daemon.json content
DAEMON_CONFIG='{
  "insecure-registries": ["registry.atoml.net:20050", "registry.atoml.net:20050"]
}'

# Ensure /etc/docker directory exists
mkdir -p /etc/docker

# Write configuration to daemon.json
echo "$DAEMON_CONFIG" > /etc/docker/daemon.json

# Restart docker service
if [ -f /etc/rc.d/rc.docker ]; then
    /etc/rc.d/rc.docker restart
    echo "Docker service restarted successfully"
else
    echo "Docker service script not found at /etc/rc.d/rc.docker"
    exit 1
fi