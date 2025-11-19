# ai-rpi-cam

Custom build of [rpicam-apps](https://github.com/raspberrypi/rpicam-apps) which contains an extra app for interfacing with [libwallaby](https://github.com/kipr/libwallaby).

## Pi Zero 2W Setup

If you wish to skip this step, you can simply flash the Pi with the latest image from the releases.
The one labeled `gadget` has:

- Gadget mode already enabled.
- `rpicam-apps-core` and `rpicam-apps` removed.
- Fully updated as of 11-18-2025.

You can also use the image labeled `gadget_rpicam`, which has all of the above, along with `rpicam-kipr` installed.

First, flash trixie-lite with the official raspberry pi imager.
Then, enable gadget mode (instructions taken from [this guide](https://github.com/charkster/rpi_gadget_mode))

1. Append the following to `/boot/config.txt`:
```
dtoverlay=dwc2
```
2. Find and remove or comment out:
```
otg_mode=1
```
3. Edit `/boot/cmdline.txt` by inserting the following text between **rootwait** and **quiet**:
```
modules-load=dwc2,g_ether g_ether.dev_addr=12:34:56:78:9a:bc g_ether.host_addr=16:23:45:78:9a:bc
```
4. Create a new udev rule file. Create `/etc/udev/rules.d/90-usb-gadget.rules` and insert the following:
```
SUBSYSTEM=="net",ACTION=="add",KERNEL=="usb0",RUN+="/sbin/ifconfig usb0 192.168.1.2 netmask 255.255.255.0",RUN+="/usr/bin/python -c 'import time; time.sleep(20)'",RUN+="/sbin/ip route add 192.168.1.1 dev usb0"
```
5. (Optional) Edit `/etc/sysctl.conf` and append the following line to the end of the file (this allows normal mode, when not a gadget):
```
net.ipv4.conf.all.ignore_routes_with_linkdown=1
```

Boot the Pi and wait for it to finish initial setup.
Once done, `ssh` into the Pi either over the network or over gadget mode (`ssh kipr@192.168.1.2`).
Remove the old `rpicam-apps` and update:

```
sudo apt purge -y rpicam-apps-core rpicam-apps && sudo apt autoremove -y --purge && sudo apt update && sudo apt full-upgrade -y
sudo reboot
```

## Installation

Check the releases for a pre-built `.deb` file.
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

### Debugging With systemd

If you installed from the `.deb` package, `rpicam-kipr` is automatically started at boot as a systemd unit.
You can view a unit's logs by running:

```{bash,eval=FALSE}
sudo journalctl -b -f -u <service-name>.service
```

So, for `rpicam-kipr`:

```{bash,eval=FALSE}
sudo journalctl -b -f -u rpicam-kipr.service
```

Flags:

- `-b`: Only show logs from current boot.
- `-f`: Emulates `tail -f` with a continuous stream.
- `-u UNIT`: Only view logs for `UNIT`, rather than viewing logs for everything systemd is tracking.

See `man journalctl` for more info.

You can also list everything systemd is currently tracking by running:

```{bash,eval=FALSE}
systemctl
```

Generally the entries suffixed with `.service` are the most pertinent.

## License

The original rpicam-apps is made available under the simplified [BSD 2-Clause license](https://spdx.org/licenses/BSD-2-Clause.html).

All changes made by KIPR and KIPR volunteers are licensed under the terms of the [GPLv3 License](LICENSE).
