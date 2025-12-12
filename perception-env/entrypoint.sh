#!/bin/bash

# Create User
USER=${USER:-root}
HOME=/root
if [ "$USER" != "root" ]; then
    echo "* enable custom user: $USER"
    useradd --create-home --shell /bin/zsh --user-group --groups adm,sudo $USER
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    if [ -z "$PASSWORD" ]; then
        echo "  set default password to \"ubuntu\""
        PASSWORD=ubuntu
    fi
    HOME=/home/$USER
    echo "$USER:$PASSWORD" | /usr/sbin/chpasswd 2> /dev/null || echo ""
    cp -r /root/{.config,.gtkrc-2.0,.asoundrc} ${HOME} 2>/dev/null
    
    # Setup oh-my-zsh for user
    if [ -d "/opt/oh-my-zsh" ]; then
        cp -r /opt/oh-my-zsh $HOME/.oh-my-zsh
        cp /opt/oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
        sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' $HOME/.zshrc
    fi

    chown -R $USER:$USER ${HOME}
    [ -d "/dev/snd" ] && chgrp -R adm /dev/snd
fi

# VNC password
VNC_PASSWORD=${PASSWORD:-ubuntu}

mkdir -p $HOME/.vnc
echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd
chown -R $USER:$USER $HOME
if [ -f "/usr/lib/novnc/app/ui.js" ]; then
    sed -i "s/password = WebUtil.getConfigVar('password');/password = '$VNC_PASSWORD'/" /usr/lib/novnc/app/ui.js || true
fi

# xstartup
XSTARTUP_PATH=$HOME/.vnc/xstartup
cat << EOF > $XSTARTUP_PATH
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
mate-session
EOF
chown $USER:$USER $XSTARTUP_PATH
chmod 755 $XSTARTUP_PATH

# Setup locale and input method (Chinese)
echo "Configuring zh_CN.UTF-8 locale and fcitx5 input method"
sed -i 's/^# *zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen || true
locale-gen zh_CN.UTF-8 || true
update-locale LANG=zh_CN.UTF-8 || true

# Set fcitx5 environment variables
IM_ENV_PATH=$HOME/.xinputrc
cat << EOF > $IM_ENV_PATH
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIM=fcitx5
EOF
chown $USER:$USER $IM_ENV_PATH

# Fix hostname resolution for vncserver
echo "Current hostname: $(hostname)"
if ! grep -q "127.0.0.1 $(hostname)" /etc/hosts; then
    echo "Adding hostname to /etc/hosts"
    echo "127.0.0.1 $(hostname)" >> /etc/hosts || echo "Failed to update /etc/hosts"
fi

# Create log file and set permissions
touch /tmp/vnc.log
chmod 666 /tmp/vnc.log

# vncserver launch
VNCRUN_PATH=$HOME/.vnc/vnc_run.sh
cat << EOF > $VNCRUN_PATH
#!/bin/sh

# Workaround for issue when image is created with "docker commit".
# Thanks to @SaadRana17
# https://github.com/Tiryoh/docker-ros2-desktop-vnc/issues/131#issuecomment-2184156856

if [ -e /tmp/.X20-lock ]; then
    rm -f /tmp/.X20-lock
fi
if [ -e /tmp/.X11-unix/X20 ]; then
    rm -f /tmp/.X11-unix/X20
fi

# Clean up any existing X11 lock files
rm -rf /tmp/.X20-lock /tmp/.X11-unix/X20

if [ $(uname -m) = "aarch64" ]; then
    LD_PRELOAD=/lib/aarch64-linux-gnu/libgcc_s.so.1 vncserver :20 -fg -geometry 1920x1080 -depth 24 -verbose > /tmp/vnc.log 2>&1
else
    vncserver :20 -fg -geometry 1920x1080 -depth 24 -verbose > /tmp/vnc.log 2>&1
fi
EOF

# Supervisor
CONF_PATH=/etc/supervisor/conf.d/supervisord.conf
cat << EOF > $CONF_PATH
[supervisord]
nodaemon=true
user=root
[program:vnc]
command=gosu '$USER' bash '$VNCRUN_PATH'
[program:novnc]
command=gosu '$USER' bash -c "websockify --web=/usr/lib/novnc 6080 localhost:5920"
[program:log]
command=tail -f /tmp/vnc.log
EOF

# colcon
BASHRC_PATH=$HOME/.bashrc
grep -F "source /opt/ros/$ROS_DISTRO/setup.bash" $BASHRC_PATH || echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> $BASHRC_PATH
grep -F "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" $BASHRC_PATH || echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> $BASHRC_PATH
chown $USER:$USER $BASHRC_PATH

# Fix rosdep permission
mkdir -p $HOME/.ros
cp -r /root/.ros/rosdep $HOME/.ros/rosdep
chown -R $USER:$USER $HOME/.ros

# Add terminator shortcut
mkdir -p $HOME/Desktop
cat << EOF > $HOME/Desktop/terminator.desktop
[Desktop Entry]
Name=Terminator
Comment=Multiple terminals in one window
TryExec=terminator
Exec=terminator
Icon=terminator
Type=Application
Categories=GNOME;GTK;Utility;TerminalEmulator;System;
StartupNotify=true
X-Ubuntu-Gettext-Domain=terminator
X-Ayatana-Desktop-Shortcuts=NewWindow;
Keywords=terminal;shell;prompt;command;commandline;
[NewWindow Shortcut Group]
Name=Open a New Window
Exec=terminator
TargetEnvironment=Unity
EOF

chown -R $USER:$USER $HOME/Desktop

# clearup
PASSWORD=
VNC_PASSWORD=

echo "============================================================================================"
echo "NOTE 1: --security-opt seccomp=unconfined flag is required to launch Ubuntu Jammy based image."
echo -e 'See \e]8;;https://github.com/Tiryoh/docker-ros2-desktop-vnc/pull/56\e\\https://github.com/Tiryoh/docker-ros2-desktop-vnc/pull/56\e]8;;\e\\'
echo "============================================================================================"

exec /bin/tini -- supervisord -n -c /etc/supervisor/supervisord.conf
