#!/usr/bin/env bash
echo "Cloning AUTOMATIC1111 WebUI repo"
cd /home/ubuntu
git clone git@github.com:AUTOMATIC1111/stable-diffusion-webui.git

echo "Mounting io2 disk for models"
sudo mkfs -t ext4 /dev/nvme2n1
sudo mkdir -p /media/models
sudo mount /dev/nvme2n1 /media/models
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

echo "Installing Dreambooth extension"
cd /home/ubuntu/stable-diffusion-webui/extensions
git clone git@github.com:d8ahazard/sd_dreambooth_extension.git
COMMIT="65d5a78abe8a132d40c88360d77670a6d9b7294e"
git checkout ${COMMIT}
#source venv/bin/activate
#export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4
#export PYTHONUNBUFFERED=true
#nohup python launch.py \
#  --listen \
#  --enable-insecure-extension-access \
#  --xformers \
#  --api \
#  --ckpt-dir /media/models/ckpt > /home/ubuntu/log.txt
