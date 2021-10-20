#!/usr/bin/env bash

set -xeo pipefail

hd=".tmp/rk64"
rf=".tmp/rk64/rootfs"
bi=".tmp/rk3328-rock64_rk64-base_2020-06-08_emmc.img"

if [ ! -f "$bi" ]; then
  curl -o "$bi.lz4" https://releases.aosc.io/os-arm64/rockchip64/xfce/rock64/rk3328-rock64_rk64-xfce_2020-06-09_emmc.img.lz4
  unlz4 "$bi.lz4"
  rm "$bi.lz4"
fi

sudo collection/roles/image_aosc/files/mounter.sh -hd "$hd" -bi "$bi" -c

sudo collection/roles/image_aosc/files/mounter.sh -hd "$hd" -bi "$bi" -p

sudo collection/roles/image_aosc/files/customizer.sh -rf "$rf"

sudo collection/roles/image_aosc/files/mounter.sh -hd "$hd" -bi "$bi" -u
