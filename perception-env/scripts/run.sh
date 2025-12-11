#!/bin/bash

IMAGE_NAME="perception-env:latest"
CONTAINER_NAME="perception-container"

echo "Running container: $CONTAINER_NAME from image: $IMAGE_NAME"

docker run -it --rm \
    --name "$CONTAINER_NAME" \
    --net=host \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    "$IMAGE_NAME"
