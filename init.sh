#!/bin/sh

read -p "Did you want to save the log ? (yes/[no]): " log
if [[ $log == "yes" ]]; then
    read -p "Which name did you want to use: " logname
    log_file="$logname.log"
    exec > >(tee -a "$log_file") 2>&1
fi

# --------------------------------
# | Set the terminal output mode |
# --------------------------------
set -e


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
read -p "Did you want to set the github mirror to gitclone.com ? (yes/[no]): " mirror
if [[ $mirror == "yes" ]]; then
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
read -p "Did you want to edit? (yes/[no]): " edit
if [[ $edit == "yes" ]]; then
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

read -p "Did you want to install tensorflow package? (yes/[no]): " tensorflow
if [[ $tensorflow == "yes" ]]; then
    # -----------------------------------------------
    # | Install the pre-built TensorFlow pip wheel  |
    # -----------------------------------------------
    echo "\e[48;5;202m Install the pre-built TensorFlow pip wheel \e[0m"
    sudo apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
    sudo -H pip3 install -U pip testresources setuptools==49.6.0 
    sudo -H pip3 install -U numpy==1.19.4 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
    sudo -H pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v45  'tensorflow<2'

    # -----------------------------------------
    # | Install TensorFlow models repository  |
    # -----------------------------------------
    echo "\e[48;5;202m Install TensorFlow models repository \e[0m"
    cd
    url="https://github.com/tensorflow/models"
    tf_models_dir="TF-models"
    if [ ! -d "$tf_models_dir" ] ; then
        git clone $url $tf_models_dir
        cd "$tf_models_dir"/research
        git checkout 5f4d34fc
        wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-aarch_64.zip
        # wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip
        unzip protobuf.zip
        ./bin/protoc object_detection/protos/*.proto --python_out=.
        sudo -H python3 setup.py install
        cd slim
        sudo -H python3 setup.py install
    fi

fi



# Install traitlets (master, to support the unlink() method)
echo "\e[48;5;172m Install traitlets \e[0m"
#sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@master
sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8

# Install JupyterLab (lock to 2.2.6, latest as of Sept 2020)
echo "\e[48;5;172m Install Jupyter Lab 2.2.6 \e[0m"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs libffi-dev libssl1.0-dev 
sudo -H pip3 install jupyter jupyterlab==2.2.6 --verbose
sudo -H jupyter labextension install @jupyter-widgets/jupyterlab-manager

jupyter lab --generate-config
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"


# Install jupyter_clickable_image_widget
echo "\e[42m Install jupyter_clickable_image_widget \e[0m"
cd
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget
git checkout tags/v0.1
sudo -H pip3 install -e .
sudo -H jupyter labextension install js
sudo -H jupyter lab build

# fix for permission error
sudo chown -R jetson:jetson /usr/local/share/jupyter/lab/settings/build_config.json

# install version of traitlets with dlink.link() feature
# (added after 4.3.3 and commits after the one below only support Python 3.7+) 
#
sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8
sudo -H jupyter lab build


# =================
# INSTALL jetcam
# =================
cd $HOME
git clone https://github.com/NVIDIA-AI-IOT/jetcam
cd jetcam
sudo -H python3 setup.py install

# =================
# INSTALL torch2trt
# =================
cd 
git clone https://github.com/NVIDIA-AI-IOT/torch2trt 
cd torch2trt 
sudo -H python3 setup.py install --plugins

# =================
# INSTALL jetracer
# =================
cd $HOME
git clone https://github.com/NVIDIA-AI-IOT/jetracer
cd jetracer
sudo -H python3 setup.py install

# ========================================
# Install other misc packages for trt_pose
# ========================================
sudo -H pip3 install tqdm cython pycocotools 
sudo apt-get install python3-matplotlib
sudo -H pip3 install traitlets
sudo -H pip3 install -U scikit-learn

# ==============================================
# Install other misc packages for point_detector
# ==============================================
sudo -H pip3 install tensorboard
sudo -H pip3 install segmentation-models-pytorch


# Install jetcard
echo "\e[44m Install jetcard \e[0m"
cd $DIR
pwd
sudo apt-get install python3-pip python3-setuptools python3-pil python3-smbus
sudo -H pip3 install flask
sudo -H python3 setup.py install

# Install jetcard display service
echo "\e[44m Install jetcard display service \e[0m"
python3 -m jetcard.create_display_service
sudo mv jetcard_display.service /etc/systemd/system/jetcard_display.service
sudo systemctl enable jetcard_display
sudo systemctl start jetcard_display

# Install jetcard jupyter service
echo "\e[44m Install jetcard jupyter service \e[0m"
python3 -m jetcard.create_jupyter_service
sudo mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
sudo systemctl enable jetcard_jupyter
sudo systemctl start jetcard_jupyter

# Make swapfile
echo "\e[46m Make swapfile \e[0m"
cd
if [ ! -f /var/swapfile ]; then
	sudo fallocate -l 4G /var/swapfile
	sudo chmod 600 /var/swapfile
	sudo mkswap /var/swapfile
	sudo swapon /var/swapfile
	sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'
else
	echo "Swapfile already exists"
fi



# Install remaining dependencies for projects
echo "\e[104m Install remaining dependencies for projects \e[0m"
sudo apt-get install python-setuptools



echo "\e[42m All done! \e[0m"

#record the time this script ends
date