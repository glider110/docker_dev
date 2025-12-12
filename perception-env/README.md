# 感知环境（Perception Environment）

本目录包含感知环境的 Docker 构建配置。

## 目录结构

- `Dockerfile`: 用于构建镜像的主 Dockerfile 文件
- `apt.txt`: APT 包管理器需要安装的包列表
- `pip.txt`: Python 包管理器需要安装的包列表
- `versions.txt`: 关键组件的版本信息
- `scripts/`: 构建和运行容器的辅助脚本
- `snapshots/`: 环境状态的文档记录

## 使用方法

### 方法一：构建镜像及运行

#### 构建镜像

```bash
./scripts/build.sh
```

#### 运行容器

```bash
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

### 方法二：从 Docker Hub 下载镜像

直接从 Docker Hub 用户主页下载预构建的镜像：
[https://hub.docker.com/repositories/godfery110](https://hub.docker.com/repositories/godfery110)

运行已下载的镜像：

```bash
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

## 访问 VNC 桌面

容器启动后，可以通过浏览器访问 VNC 桌面。

- **本地访问**:
  - `http://localhost:6080/`
  - `http://127.0.0.1:6080/`

- **局域网访问**:
  首先需要查看本机的局域网 IP 地址，然后通过该 IP 访问。例如，如果本机 IP 是 `10.10.70.2`，则访问地址为：
  - `http://10.10.70.2:6080/`

![2025-12-12_18-39](.README.assets/2025-12-12_18-39.png)
