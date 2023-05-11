#!/usr/bin/env bash
cd /home/ubuntu/stable-diffusion-webui
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4
export LD_LIBRARY_PATH=/usr/local/cuda-12.1/targets/x86_64-linux/lib
export PYTHONUNBUFFERED=true
nohup python launch.py \
  --listen \
  --enable-insecure-extension-access \
  --xformers \
  --api \
  --ckpt-dir /media/models/ckpt > /home/ubuntu/log.txt&
cd
tail -f log.txt
