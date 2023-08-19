# Get the root permission
sudo -v

# Change domestic mirror source for Jetson Nano (Only for Chinese)
sudo sh -c 'echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse" > /etc/apt/sources.list'

# Install pip and some python dependencies
echo -e "\e[104m Install pip and some python dependencies \e[0m"
sudo apt-get update
sudo apt install -y python3-pip python3-setuptools python3-pil python3-smbus python3-matplotlib cmake curl
sudo -H pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
sudo -H pip3 install --upgrade pip

# Install jtop
echo -e "\e[100m Install jtop \e[0m"
sudo -H pip3 install jetson-stats 

# Install jetson-fan-ctl
echo -e "\e[100m Install jetson-fan-ctl \e[0m"
# Only for Chinese
# git clone https://gitclone.com/github.com/Pyrestone/jetson-fan-ctl.git
git clone github.com/Pyrestone/jetson-fan-ctl.git
cd jetson-fan-ctl
sudo ./install.sh
cd ../
echo -e "\e[43m You can also customize fans by editing /etc/automagic-fan/config.json with your favorite editor\e[0m"

# Install the pre-built PyTorch pip wheel 
echo -e "\e[45m Install the pre-built PyTorch pip wheel  \e[0m"
cd
wget -N https://developer.download.nvidia.com/compute/redist/jp/v461/pytorch/torch-1.11.0a0+17540c5+nv22.01-cp36-cp36m-linux_aarch64.whl
sudo apt-get install -y libopenblas-base libopenmpi-dev 
sudo -H pip3 install Cython
sudo -H pip3 install numpy torch-1.11.0a0+17540c5+nv22.01-cp36-cp36m-linux_aarch64.whl

# Install torchvision package
echo -e "\e[45m Install torchvision package \e[0m"
cd
# git clone https://gitclone.com/https://github.com/pytorch/vision torchvision
git clone https://github.com/pytorch/vision torchvision
cd torchvision
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libomp-dev
git checkout tags/v0.7.0
sudo -H python3 setup.py install
cd  ../
sudo -H pip3 install pillow
