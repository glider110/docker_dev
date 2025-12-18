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

# Install websockify for noVNC proxy
RUN pip install websockify==0.10.0 -i https://pypi.tuna.tsinghua.edu.cn/simple

# Configure git to use HTTP/1.1 to avoid protocol errors
RUN git config --global http.version HTTP/1.1

# noVNC setup (use tarball to avoid git issues)
RUN curl -L https://codeload.github.com/AtsushiSaito/noVNC/tar.gz/refs/heads/add_clipboard_support -o /tmp/novnc.tar.gz && \
    mkdir -p /usr/lib/novnc && \
    tar -xzf /tmp/novnc.tar.gz -C /usr/lib/novnc --strip-components=1 && \
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
RUN git clone https://gitclone.com/github.com/ohmyzsh/ohmyzsh.git /opt/oh-my-zsh && \
    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git /opt/oh-my-zsh/custom/themes/powerlevel10k && \
    curl -L https://gitee.com/romkatv/powerlevel10k/raw/master/config/p10k-lean.zsh -o /opt/p10k.zsh

# Entrypoint
COPY ./entrypoint.sh /
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "/entrypoint.sh" ]

ENV USER=godfery
ENV PASSWD=1

# Install latest Google Chrome
RUN wget -qO - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y google-chrome-stable && \
    apt-get autoclean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install latest Visual Studio Code
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list && \
    apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y code && \
    apt-get autoclean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
