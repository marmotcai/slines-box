#!/bin/bash

# Install poetry
curl -sSL https://install.python-poetry.org | python3 -

# Add poetry to PATH 这个命令会配置Poetry以在项目目录中创建虚拟环境，而不是全局虚拟环境目录。
poetry config virtualenvs.in-project true

# Initialize poetry
poetry init