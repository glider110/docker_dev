# Copyright 2020-2023 Tiryoh<tiryoh@gmail.com>
# Licensed under the Apache License, Version 2.0

FROM ubuntu:jammy

ARG TARGETPLATFORM
LABEL maintainer="Tiryoh<tiryoh@gmail.com>"

SHELL ["/bin/bash", "-c"]

# Copy configuration files
COPY apt.txt /tmp/apt.txt
COPY pip.txt /tmp/pip.txt
COPY versions.txt /tmp/versions.txt

# Change apt source to Tsinghua
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# Upgrade OS and Install APT packages
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        wget curl gnupg2 lsb-release && \
    # Setup VSCodium repo
    wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        -O /usr/share/keyrings/vscodium-archive-keyring.asc && \
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
        | tee /etc/apt/sources.list.d/vscodium.list && \
    # Setup ROS repo
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update -q && \
    # Install packages from apt.txt
    # Filter out comments and empty lines
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        $(grep -vE "^\s*#" /tmp/apt.txt | tr "\n" " ") && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install -r /tmp/pip.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# noVNC setup
RUN git clone https://mirror.ghproxy.com/https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support /usr/lib/novnc && \
    ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html && \
    sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" /usr/lib/novnc/app/ui.js

# Disable auto update and crash report
RUN sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades && \
    sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# ROS Setup
ENV ROS_DISTRO humble
RUN mkdir -p /etc/ros/rosdep/sources.list.d/ && \
    echo "yaml https://mirrors.tuna.tsinghua.edu.cn/rosdistro/rosdep/osx-homebrew.yaml osx" > /etc/ros/rosdep/sources.list.d/20-default.list && \
    echo "yaml https://mirrors.tuna.tsinghua.edu.cn/rosdistro/rosdep/base.yaml" >> /etc/ros/rosdep/sources.list.d/20-default.list && \
    echo "yaml https://mirrors.tuna.tsinghua.edu.cn/rosdistro/rosdep/python.yaml" >> /etc/ros/rosdep/sources.list.d/20-default.list && \
    echo "yaml https://mirrors.tuna.tsinghua.edu.cn/rosdistro/rosdep/ruby.yaml" >> /etc/ros/rosdep/sources.list.d/20-default.list && \
    export ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml && \
    rosdep update

# Enable apt-get completion
RUN rm /etc/apt/apt.conf.d/docker-clean

# Install oh-my-zsh
RUN git clone https://mirror.ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git /opt/oh-my-zsh

# Entrypoint
COPY ./entrypoint.sh /
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "/entrypoint.sh" ]

ENV USER=ubuntu
ENV PASSWD=1
