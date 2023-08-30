#!/usr/bin/env bash
cd /home/ubuntu/stable-diffusion-webui
source venv/bin/activate
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4
export LD_LIBRARY_PATH=/usr/local/cuda-12.1/targets/x86_64-linux/lib
export PYTHONUNBUFFERED=true
nohup python launch.py \
  --listen \
  --skip-python-version-check \
  --enable-insecure-extension-access \
  --xformers \
  --api \
  --skip-version-check \
  --skip-install \
  --ckpt-dir /home/ubuntu/stable-diffusion-webui/models/Stable-diffusion > /home/ubuntu/log.txt 2>&1 &
cd
tail -f log.txt
