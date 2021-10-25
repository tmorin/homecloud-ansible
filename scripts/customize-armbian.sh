#!/usr/bin/env bash

set -xeo pipefail

hd=".tmp/armbian"
rf=".tmp/armbian/rootfs"
bi=".tmp/Armbian_20.08.1_Rock64_buster_legacy_4.4.213.img"

if [ ! -f "$bi" ]; then
  curl -o "$bi.xz" https://archive.armbian.com/rock64/archive/Armbian_20.08.1_Rock64_buster_legacy_4.4.213.img.xz
  unxz "$bi.xz"
fi

sudo collection/roles/image_armbian/files/mounter.sh -hd "$hd" -bi "$bi" -c

sudo collection/roles/image_armbian/files/mounter.sh -hd "$hd" -bi "$bi" -p

sudo collection/roles/image_armbian/files/customizer.sh -rf "$rf" -dlr

sudo collection/roles/image_armbian/files/mounter.sh -hd "$hd" -bi "$bi" -u
