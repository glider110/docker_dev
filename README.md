# Docker 镜像使用说明（Docker Hub: godfery110）

本仓库对应的镜像托管在 Docker Hub 账号 `godfery110` 下，包含桌面 + VNC + ROS Humble 的开发环境，适合在 Linux 主机上通过浏览器访问远程桌面进行开发。

- Docker Hub 用户主页：https://hub.docker.com/repositories/godfery110
- 主要镜像：
  - `godfery110/perception_dev`（GitHub Actions 自动构建、推送）
  - 你也可以本地构建 `perception-env:latest` 并按需打标签推送到 Docker Hub

## 镜像标签策略

GitHub Actions 会为 `godfery110/perception_dev` 推送以下标签：
- `latest`：始终指向最新一次构建
- 短 SHA：如 `ea22702`（对应提交哈希的前 7 位）
- 日期标签：如 `20251212`（构建当天的日期）

你可以在镜像详情页中选择特定标签拉取与使用。

## 快速开始

### 拉取镜像

```bash
# 拉取最新版本
docker pull godfery110/perception_dev:latest

# 或者拉取指定版本（示例）
docker pull godfery110/perception_dev:20251212
```

### 运行容器（推荐参数）

镜像内预置用户为 `godfery`，默认密码为 `1`。VNC 端口通过 websockify 暴露为 `6080`，浏览器访问 http://127.0.0.1:6080 即可进入桌面。

```bash
docker run -d \
  --name perception-desktop \
  --network=host \
  --privileged \
  -v /dev:/dev \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ~/docker_ws:/home/godfery/docker_ws \
  -v ~/project:/home/godfery/project \
  -v ~/workspace/:/home/godfery/workspace \
  -v ~/docker_persist/home_godfery:/home/godfery \
  -e VNC_PASSWORD=1 \
  -e VNC_RESOLUTION=1920x1080 \
  godfery110/perception_dev:latest
```

启动后，打开浏览器访问 `http://127.0.0.1:6080`，输入 VNC 密码（默认 `1`）进入桌面。

> 注：Ubuntu Jammy 基础镜像在某些场景需要 `--security-opt seccomp=unconfined`，如遇到桌面/ROS 图形异常，可加上该参数。

### 代理（可选）

如果你需要在容器内使用网络代理，可设置：

```bash
-e http_proxy=http://127.0.0.1:7890 \
-e https_proxy=http://127.0.0.1:7890 \
-e all_proxy=socks5://127.0.0.1:7890 \
```

请按你的主机代理端口与协议进行调整。

## 组件说明

- 桌面：Ubuntu Mate Desktop
- 远程访问：VNC + noVNC（Web 访问 6080），websockify 代理
- Shell：默认用户 `godfery`（支持 sudo），默认 shell 为 zsh（可改为 bash）
- 开发工具：
  - VS Code（`code`）
  - Google Chrome（`google-chrome`）
- ROS：ROS 2 Humble，已配置国内镜像与 rosdep 源（清华）
- 输入法：fcitx5（已配置中文环境变量与 zh_CN.UTF-8 语言包）

## 常用命令

```bash
# 进入容器（交互）
docker exec -it perception-desktop bash

# 查看 VNC 日志
docker exec -it perception-desktop tail -n 200 /tmp/vnc.log

# 停止 / 启动 / 删除容器
docker stop perception-desktop
docker start perception-desktop
docker rm -f perception-desktop
```

## 本地构建与推送（可选）

你也可以直接从本仓库本地构建并推送到你的 Docker Hub：

```bash
# 在 perception-env 目录构建
cd perception-env
./scripts/build.sh

# 给本地镜像打标签并推送到你的仓库（示例）
docker tag perception-env:latest godfery110/perception_dev:local
docker push godfery110/perception_dev:local
```

> 如果你使用的是公司/家庭网络的镜像加速服务，拉取基础镜像或 GitHub 源失败时，可临时禁用 Docker 的 registry mirror 或确保镜像源可匿名访问。

## 故障排查

- 浏览器访问 6080 报错或空白：
  - 检查 `supervisor` 的 novnc 进程是否运行：`docker logs perception-desktop`
  - 确保端口与 `--network=host` 或端口映射设置正确
- 基础镜像拉取失败（401 Unauthorized）：
  - 检查 `/etc/docker/daemon.json` 中的 registry mirrors 设置，必要时禁用或更换镜像源
- 输入法不可用：
  - 打开 fcitx5 配置工具，添加中文输入法（拼音等）；如需自动启动，可在会话启动脚本加入 `fcitx5 &`

---

有任何功能需求（如默认改用 bash、添加更多开发包、固定特定 noVNC 版本等），欢迎在仓库里开 Issue 或留言。 