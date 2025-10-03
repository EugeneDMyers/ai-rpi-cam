#!/bin/sh

docker build -t rpi-aarch64-builder:bookworm .
/var/home/tom/Documents/work/camera/ai-rpi-cam

SRC="$HOME/Documents/work/camera/ai-rpi-cam"
OUT="$HOME/Documents/work/camera/ai-rpi-cam/out"
mkdir -p "$OUT"

docker run \
  -v "$SRC":/work/src \
  -v "$OUT":/work/out \
  rpi-aarch64-builder:bookworm \
  bash "rpi-build.sh"
