#!/usr/bin/env bash

STABLE_DIFFUSION_WEBUI_VERSION="v1.4.0"
DREAMBOOTH_TAG="1.0.14"

echo "Install dependencies"
sudo apt update
sudo apt -y install jq python3.10-venv libtcmalloc-minimal4 git git-lfs zip unzip plocate libcairo2-dev python3-dev
git lfs install

echo "Installing Github host keys"
ssh-keygen -R github.com
curl -L https://api.github.com/meta | jq -r '.ssh_keys | .[]' | sed -e 's/^/github.com /' >> ~/.ssh/known_hosts

echo "Cloning Stable Diffusion WebUI repo"
cd /home/ubuntu
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd /home/ubuntu/stable-diffusion-webui
echo "Checking out Stable Diffusion WebUI version: ${STABLE_DIFFUSION_WEBUI_VERSION}"
git checkout ${STABLE_DIFFUSION_WEBUI_VERSION}

echo "Download Stable Diffusion model"
cd /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors

echo "Download Stable Diffusion VAE"
cd /home/ubuntu/stable-diffusion-webui/models/VAE
wget https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

echo "Installing ControlNet extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone https://github.com/Mikubill/sd-webui-controlnet.git

echo "Installing Dreambooth extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone https://github.com/d8ahazard/sd_dreambooth_extension.git
cd sd_dreambooth_extension
echo "Checking out Dreambooth commit: ${DREAMBOOTH_TAG}"
git checkout ${DREAMBOOTH_TAG}

echo "Install CUDA"
cd /home/ubuntu
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt -y install cuda=11.8.0-1
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
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip3 install xformers

# Reboot for the Nvidia GPU to be used
sudo reboot
