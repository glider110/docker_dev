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
```
