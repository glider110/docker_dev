#!/bin/bash

IMAGE_NAME="perception-env:latest"
CONTAINER_NAME="perception-env-v2"

echo "Running container: $CONTAINER_NAME from image: $IMAGE_NAME"

# Remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker stop "$CONTAINER_NAME" 2>/dev/null || true
  docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

docker run -d \
  --name "$CONTAINER_NAME" \
  --network=host \
  --privileged \
  -v /dev:/dev \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ~/docker_ws:/home/godfery/docker_ws \
  -v ~/project:/home/godfery/project \
  -v ~/workspace/:/home/godfery/workspace \
  -v ~/docker_persist/home_godfery:/home/godfery \
  -e VNC_RESOLUTION=1920x1080 \
  -e VNC_PASSWORD=1 \
  -e http_proxy=http://127.0.0.1:7890 \
  -e https_proxy=http://127.0.0.1:7890 \
  -e all_proxy=socks5://127.0.0.1:7890 \
  "$IMAGE_NAME"
