FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 LANG=C.UTF-8

# Core toolchain + build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates curl wget file \
    meson ninja-build pkg-config python3 python3-pip \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
    llvm cmake

RUN rm -rf /var/lib/apt/lists/*

# Workspace layout inside container
RUN mkdir -p /work/src /work/out /opt/crossfiles

# Meson cross file
#COPY --chown=root:root ./container/rpi-aarch64.ini /opt/crossfiles/rpi-aarch64.ini

# Compiles using meson
COPY --chown=root:root ./container/rpi-build.sh /usr/local/bin/rpi-build.sh
RUN chmod +x /usr/local/bin/rpi-build.sh

# Debian package control file
#COPY --chown=root:root ./packaging/control /opt/control

# Wrapper script to launch camera app
#COPY --chown=root:root --chmod=555 ./packaging/kipr-camera /opt/kipr-camera

# Default working directory
WORKDIR /work
