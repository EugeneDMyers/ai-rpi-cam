# ai-rpi-cam

Custom build of [rpicam-apps](https://github.com/raspberrypi/rpicam-apps) which contains an extra app for interfacing with [libwallaby](https://github.com/kipr/libwallaby).

## Installation

First check for a prebuilt deb file.
It should work on Trixie-based Raspberry Pi OS.
To use it with the Wombat, make sure you have enabled gadget mode for the Pi following [this guide](https://github.com/charkster/rpi_gadget_mode).
If you want to build from scratch, read on.

### Docker cross-compilation (recommended)

Pull the sysroot with git LFS.
It is over a gigabyte, so it may take a while.
```
git lfs pull
```

Ensure that you have Docker installed and set up for your user.
From the root of this repo run:

```bash
./build.sh
```

It will place all logs and build artifacts in an `out` directory.
You can then copy `out/rpicam-apps-kipr.deb` to a Trixie-based Raspberry Pi OS and install:

```bash
sudo apt install ./rpicam-apps-kipr.deb
```

### Local build on a Pi

Install build dependencies:

```bash
sudo apt install -y git meson libcamera-dev libboost-all-dev libswscale-dev libavcodec-dev libavdevice-dev libexif-dev libjpeg-dev libtiff5-dev libpng-dev libopencv-dev libdrm-dev cmake libexif-dev liblapack-dev libblas-dev libarmadillo-dev
```

Then compile and install with `meson`:

>[!TIP]
>When compiling on a memory constrained like a Pi, consider adding `-j1` to the compile command to reduce the chances of build failure due to running out of memory.
>If it still fails, consider using the Docker build procedure.

```bash
meson setup build --prefix /usr -Denable_libav=enabled -Denable_drm=disabled -Denable_egl=disabled -Denable_qt=disabled -Denable_opencv=enabled -Denable_tflite=disabled -Denable_hailo=disabled -Denable_imx500=true -Ddownload_imx500_models=true
meson compile -C build
sudo meson install -C build
```

## Running

You can run the `rpicam-kipr` app manually like this:

```bash
LD_PRELOAD=/usr/lib/librpicam_app.so rpicam-kipr -o udp://192.168.1.1:9000 --post-process-file /usr/share/rpi-camera-assets/kipr_mobilenet_ssd.json -t0
```
