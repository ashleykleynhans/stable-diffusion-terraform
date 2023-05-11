#!/usr/bin/env bash
echo "Install dependencies"
sudo apt -y install jq python3.10-venv libtcmalloc-minimal4 git git-lfs
git lfs install

echo "Installing Github host keys"
ssh-keygen -R github.com
curl -L https://api.github.com/meta | jq -r '.ssh_keys | .[]' | sed -e 's/^/github.com /' >> ~/.ssh/known_hosts

echo "Cloning AUTOMATIC1111 WebUI repo"
cd /home/ubuntu
git clone git@github.com:AUTOMATIC1111/stable-diffusion-webui.git

echo "Mounting io2 disk for models"
sudo mkfs -t ext4 /dev/nvme2n1
sudo mkdir -p /media/models
sudo mount -t ext4 /dev/nvme2n1 /media/models
sudo chown ubuntu:ubuntu /media/models
sudo mkdir -p /media/models/ckpt
sudo chown ubuntu:ubuntu /media/models/ckpt

echo "Download some models"
cd /media/models/ckpt
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt
wget https://huggingface.co/prompthero/openjourney/resolve/main/mdjrny-v4.ckpt
wget -O protogenX34Photorealism_1.safetensors https://civitai.com/api/download/models/4048

echo "Setting up Stable Diffusion"
COMMIT="889b851a5260ce869a3286ad15d17d1bbb1da0a7"
cd /home/ubuntu/stable-diffusion-webui
git pull
git checkout ${COMMIT}

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
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt -y install cuda

echo "Check GPU"
lspci | grep -i nvidia
nvidia-smi

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

