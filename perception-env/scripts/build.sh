#!/bin/bash
set -e

# 获取脚本所在目录的上一级目录作为构建上下文
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONTEXT_DIR="$(dirname "$SCRIPT_DIR")"

# 复制 entrypoint.sh 到构建上下文 (如果它不在那里)
# 假设 entrypoint.sh 应该在 perception-env 根目录下，如果不在，我们需要从原始位置复制或者创建一个
# 这里假设用户会把 entrypoint.sh 放在 perception-env 目录下
if [ ! -f "$CONTEXT_DIR/entrypoint.sh" ]; then
    echo "Warning: entrypoint.sh not found in $CONTEXT_DIR. Please ensure it exists."
    # 尝试从原始位置复制 (仅用于演示，实际应由用户管理)
    if [ -f "../perception_dev_docker_origin/entrypoint.sh" ]; then
        cp "../perception_dev_docker_origin/entrypoint.sh" "$CONTEXT_DIR/"
        echo "Copied entrypoint.sh from origin."
    fi
fi

IMAGE_NAME="perception-env:latest"

echo "Building Docker image: $IMAGE_NAME from $CONTEXT_DIR"
docker build -t "$IMAGE_NAME" "$CONTEXT_DIR"
