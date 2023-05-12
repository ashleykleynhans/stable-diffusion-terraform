#!/usr/bin/env bash

DREAMBOOTH_COMMIT="32b28b67ccf91fd62394990738c8205455579a20"

echo "Install dependencies"
sudo apt update
sudo apt -y install jq python3.10-venv libtcmalloc-minimal4 git git-lfs unzip plocate libcairo2-dev
git lfs install

echo "Installing Github host keys"
ssh-keygen -R github.com
curl -L https://api.github.com/meta | jq -r '.ssh_keys | .[]' | sed -e 's/^/github.com /' >> ~/.ssh/known_hosts

echo "Cloning AUTOMATIC1111 Stable Diffusion WebUI repo"
cd /home/ubuntu
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd /home/ubuntu/stable-diffusion-webui
echo "Checking out AUTOMATIC1111 1.1.1 release"
git checkout 1.1.1

echo "Download Stable Diffusion model"
cd /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt

echo "Installing ControlNet extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git

echo "Installing Dreambooth extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone https://github.com/d8ahazard/sd_dreambooth_extension.git
cd sd_dreambooth_extension
echo "Checking out dev branch"
git checkout dev
echo "Checking out Dreambooth commit: ${DREAMBOOTH_COMMIT}"

echo "Install CUDA"
cd /home/ubuntu
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt -y install cuda
rm cuda-keyring_1.1-1_all.deb

echo "Check GPU"
lspci | grep -i nvidia
nvidia-smi

echo "Installing Python modules for the WebUI and Dreambooth"
cd /home/ubuntu/stable-diffusion-webui
python3 -m venv venv
source venv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
pip3 install -r requirements_versions.txt
cd extensions/sd_dreambooth_extension/
pip3 install -r requirements.txt
pip install --force-reinstall torch torchaudio torchvision --index-url https://download.pytorch.org/whl/cu118
pip install --force-reinstall --no-deps --pre xformers

echo "Compiling and installing bitsandbytes for CUDA 12.1"
rm -rf /home/ubuntu/stable-diffusion-webui/venv/lib/python3.10/site-packages/bitsandbytes
cd /home/ubuntu
git clone https://github.com/TimDettmers/bitsandbytes.git
cd bitsandbytes
cp -R /usr/local/cuda-12.1/targets/x86_64-linux/include/* /home/ubuntu/bitsandbytes/include
sudo ln -s /usr/local/cuda-12.1/targets/x86_64-linux/lib/libcusparse.so.12 /usr/local/cuda-12.1/targets/x86_64-linux/lib/libcusparse.so.11
export PATH="/usr/local/cuda-12.1/bin:/usr/local/cuda-12.1/nvvm/bin:$PATH"
LD_LIBRARY_PATH=/usr/local/cuda-12.1/targets/x86_64-linux/lib CUDA_VERSION=121 make cuda12x
python setup.py install

echo "Verifying bitsandbytes module installation"
export LD_LIBRARY_PATH=/usr/local/cuda-12.1/targets/x86_64-linux/lib
python -m bitsandbytes

# Reboot for the Nvidia GPU to be used
sudo reboot
