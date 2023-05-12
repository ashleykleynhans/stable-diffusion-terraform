#!/usr/bin/env bash
echo "Install dependencies"
sudo apt -y install jq python3.10-venv libtcmalloc-minimal4 git git-lfs unzip plocate
git lfs install

echo "Installing Github host keys"
ssh-keygen -R github.com
curl -L https://api.github.com/meta | jq -r '.ssh_keys | .[]' | sed -e 's/^/github.com /' >> ~/.ssh/known_hosts

echo "Cloning AUTOMATIC1111 Stable Diffusion WebUI repo"
cd /home/ubuntu
git clone git@github.com:AUTOMATIC1111/stable-diffusion-webui.git
COMMIT="889b851a5260ce869a3286ad15d17d1bbb1da0a7"
cd /home/ubuntu/stable-diffusion-webui
git pull
git checkout ${COMMIT}

echo "Download Stable Diffusion model"
cd /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt

echo "Installing ControlNet extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone git@github.com:Mikubill/sd-webui-controlnet.git

echo "Installing Dreambooth extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone git@github.com:d8ahazard/sd_dreambooth_extension.git
cd sd_dreambooth_extension
COMMIT="65d5a78abe8a132d40c88360d77670a6d9b7294e"
git checkout ${COMMIT}

echo "Install CUDA"
cd /home/ubuntu
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt -y install cuda

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
git clone git@github.com:TimDettmers/bitsandbytes.git
cd bitsandbytes
cp -R /usr/local/cuda-12.1/targets/x86_64-linux/include/* /home/ubuntu/bitsandbytes/include
sudo ln -s /usr/local/cuda-12.1/targets/x86_64-linux/lib/libcusparse.so.12 /usr/local/cuda-12.1/targets/x86_64-linux/lib/libcusparse.so.11
export PATH="/usr/local/cuda-12.1/bin:/usr/local/cuda-12.1/nvvm/bin:$PATH"
LD_LIBRARY_PATH=/usr/local/cuda-12.1/targets/x86_64-linux/lib CUDA_VERSION=121 make cuda12x
python setup.py install

# Reboot for the Nvidia GPU to be used
sudo reboot
