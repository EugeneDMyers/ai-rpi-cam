#!/usr/bin/env bash
# Maximum safety - don't allow commands to silently fail
set -euo pipefail

SRC_DIR="/work/src"
OUT_DIR="/work/out"
BUILD_DIR="${OUT_DIR}/build"
STAGE_DIR="${OUT_DIR}/stage"
LOG_DIR="${OUT_DIR}/logs"
CROSSFILE="${SRC_DIR}/container/rpi-aarch64.ini"
PKG_DIR="${SRC_DIR}/DEBIAN"

mkdir -p "$BUILD_DIR" "$STAGE_DIR" "$LOG_DIR"

# Create symlinks for /lib and /lib64 in sysroot
# This probably isn't necessary
[ -e /opt/sysroot/lib ]   || ln -s usr/lib /opt/sysroot/lib
[ -e /opt/sysroot/lib64 ] || ln -s usr/lib /opt/sysroot/lib64

LOG_FILE="${LOG_DIR}/build-$(date -Iseconds).log"

# Make pkg-config look inside cross sysroot
export PKG_CONFIG_SYSROOT_DIR="/opt/sysroot"
export PKG_CONFIG_LIBDIR="/opt/sysroot/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/sysroot/usr/share/pkgconfig"
# Make sure host pkg-config doesn't leak into container
unset PKG_CONFIG_PATH || true

# Ensure boost libs resolve properly
export BOOST_INCLUDEDIR="/opt/sysroot/usr/include"
export BOOST_LIBRARYDIR="/opt/sysroot/usr/lib/aarch64-linux-gnu"

cd "${SRC_DIR}"

echo "meson setup ${BUILD_DIR} ..."
meson setup "${BUILD_DIR}" --cross-file "${CROSSFILE}" --buildtype release --prefix /usr -Denable_libav=enabled -Denable_drm=disabled -Denable_egl=disabled -Denable_qt=disabled -Denable_opencv=enabled -Denable_tflite=disabled -Denable_hailo=disabled -Denable_imx500=true -Ddownload_imx500_models=true 2>&1 | tee -a "${LOG_FILE}"

echo "meson compile ..."
meson compile -C "${BUILD_DIR}" -v 2>&1 | tee -a "${LOG_FILE}"

echo "meson install into staging dir ..."
DESTDIR="${STAGE_DIR}" meson install -C "${BUILD_DIR}" 2>&1 | tee -a "${LOG_FILE}"
echo "Artifacts staged: ${STAGE_DIR}"

mkdir -p "${STAGE_DIR}/lib/systemd/system"
cp "${SRC_DIR}/rpicam-kipr.service" "${STAGE_DIR}/lib/systemd/system"

cd "${STAGE_DIR}"
cp -r "${PKG_DIR}" "${STAGE_DIR}/DEBIAN"
dpkg-deb -b "${STAGE_DIR}"
mv "${OUT_DIR}/stage.deb" "${OUT_DIR}/rpicam-apps-kipr.deb"
