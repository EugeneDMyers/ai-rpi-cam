#!/bin/sh

docker build -t rpi-aarch64-builder:trixie .

[ -d ./container/sysroot ] || tar -C ./container -xzf ./container/sysroot.tar.gz

SRC="$(pwd)"
OUT="$(pwd)/out"
mkdir -p "$OUT"

docker run \
  -v "$SRC":/work/src \
  -v "$OUT":/work/out \
  --mount type=bind,src=./container/sysroot,dst=/opt/sysroot \
  rpi-aarch64-builder:trixie \
  bash "rpi-build.sh"
