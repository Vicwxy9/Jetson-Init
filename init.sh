#!/bin/sh

set -e

# Record the time this script starts
date


# ---------------------------
# | Get the root permission |
# ---------------------------
echo "\e[100m [INFO] Please input the root's password \e[0m"
sudo -v


# --------------------------------------------------------------------
# | Change domestic mirror source for Jetson Nano (Only for Chinese) |
# --------------------------------------------------------------------
echo "\e[100m [INFO] Change domestic mirror source for Jetson Nano \e[0m"
sudo sh -c 'echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse" > /etc/apt/sources.list'


# --------------------------------------------
# | Install pip and some python dependencies |
# --------------------------------------------
echo "\e[104m [INFO] Install pip and some python dependencies \e[0m"
# sudo apt-get update
sudo apt install -y python3-pip python3-setuptools python3-pil python3-smbus python3-matplotlib cmake curl
sudo -H pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
sudo -H pip3 install --upgrade pip


# ----------------
# | Install jtop |
# ----------------
echo "\e[100m [INFO] Install jtop \e[0m"
sudo -H pip3 install jetson-stats 


# ---------------------------------------------
# | Set the github mirror ( Only for Chinese) |
# ---------------------------------------------
read -p "Did you want to set the github mirror to gitclone.com ? (yes/[no]): " choice
if [[ $choice == "yes" ]]; then
    echo "\e[100m [INFO] Set the github mirror ( Only for Chinese) \e[0m"
    git config --global url."https://gitclone.com/".insteadOf https://
fi


# --------------------------
# | Install jetson-fan-ctl |
# --------------------------
echo "\e[100m [INFO] Install jetson-fan-ctl \e[0m"
git clone github.com/Pyrestone/jetson-fan-ctl.git
cd jetson-fan-ctl
sudo ./install.sh
cd ../
echo "\e[43m [Optional] You can also customize fans by editing /etc/automagic-fan/config.json with vim\e[0m"
read -p "Did you want to edit? (yes/[no]): " choice
if [[ $choice == "yes" ]]; then
    sudo vim /etc/automagic-fan/config.json
fi


# --------------------------------------------
# | Install the pre-built PyTorch pip wheel  |
# --------------------------------------------
echo "\e[45m [INFO] Install the pre-built PyTorch pip wheel  \e[0m"
cd
wget -N https://developer.download.nvidia.com/compute/redist/jp/v461/pytorch/torch-1.11.0a0+17540c5+nv22.01-cp36-cp36m-linux_aarch64.whl
sudo apt-get install -y libopenblas-base libopenmpi-dev 
sudo -H pip3 install Cython
sudo -H pip3 install numpy torch-1.11.0a0+17540c5+nv22.01-cp36-cp36m-linux_aarch64.whl


# --------------------------------
# | Install torchvision package  |
# --------------------------------
echo "\e[45m Install torchvision package \e[0m"
cd
git clone https://github.com/pytorch/vision torchvision
cd torchvision
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libomp-dev
git checkout tags/v0.7.0
sudo -H python3 setup.py install
cd  ../
sudo -H pip3 install pillow


# -------------------------------------
# | pip dependencies for pytorch-ssd  |
# -------------------------------------
echo "\e[45m Install dependencies for pytorch-ssd \e[0m"
sudo -H pip3 install --verbose --upgrade Cython && \
sudo -H pip3 install --verbose boto3 pandas
