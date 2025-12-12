# Perception Environment

This directory contains the Docker build configuration for the perception environment.

## Structure

- `Dockerfile`: The main Dockerfile for building the image.
- `apt.txt`: List of APT packages to install.
- `pip.txt`: List of Python packages to install.
- `versions.txt`: Version information for key components.
- `scripts/`: Helper scripts for building and running the container.
- `snapshots/`: Documentation of environment states.

## Usage

### Build

```bash
./scripts/build.sh
```

### Run

```bash
./scripts/run.sh


docker run -d \
  --name perception-desktop-v3 \
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
  perception-env:latest
```
