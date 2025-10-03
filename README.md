# ai-rpi-cam

Custom build of [rpicam-apps](https://github.com/raspberrypi/rpicam-apps) which contains an extra app for interfacing with [libwallaby](https://github.com/kipr/libwallaby).

## Docker cross-compilation (recommended)

Pull the sysroot with git LFS.
It is about 1.2G, so this may take a while.
```
git lfs pull
```

Ensure that you have Docker installed and set up for your user.
Inspect the `build.sh` script to ensure the paths are correct, then run:

```bash
./build.sh
```

It will place all logs and build artifacts into an `out` directory.
You can then copy `out/rpicam-apps-kipr.deb` to a Bookworm-based Raspberry Pi OS and install:

```bash
sudo apt install ./kipr-camera.deb
```
>[!NOTE]
>This will also install all required dependencies!

## Local build on a Pi

Install build dependencies:

```bash
sudo apt install -y git meson libcamera-dev libboost-all-dev libswscale-dev libavcodec-dev libavdevice-dev libexif-dev libjpeg-dev libtiff5-dev libpng-dev libopencv-dev libdrm-dev cmake libexif-dev liblapack-dev libblas-dev libarmadillo-dev
```

Then compile with `meson`:

>[!TIP]
>When compiling on a memory constrained like the Zero 2 W, you should add `-j1` to the compile command to reduce the chances of build failure due to running out of memory.
>If it still fails, consider using the Docker build procedure.

```bash
meson setup build --prefix /usr/local -Denable_libav=enabled -Denable_drm=disabled -Denable_egl=disabled -Denable_qt=disabled -Denable_opencv=enabled -Denable_tflite=disabled -Denable_hailo=disabled -Denable_imx500=true -Ddownload_imx500_models=true
meson compile -C build
sudo meson install -C build
```

## Running

You can run the `rpicam-kipr` app manually like this:

```bash
LD_PRELOAD=/usr/local/lib/librpicam_app.so rpicam-kipr --rotation 1 -o udp://192.168.1.1:9000 --post-process-file /usr/local/share/rpi-camera-assets/kipr_mobilenet_ssd.json
```

Or, if you installed the deb package from a Docker build, you can use the included `kipr-camera` wrapper.

```bash
kipr-camera
```
