#!/usr/bin/env bash

ACTION=""
HOST_DIRECTORY=""
IMAGE_FILE=""
BASE_IMAGE_FILE=""
MOUNT_DIRECTORY=""

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case ${key} in
        -c|--clean)
        ACTION="clean"
        shift
        ;;
        -p|--prepare)
        ACTION="prepare"
        shift
        ;;
        -m|--mount)
        ACTION="mount"
        shift
        ;;
        -u|--umount)
        ACTION="umount"
        shift
        ;;
        -hd|--host-directory)
        HOST_DIRECTORY="$2"
        shift
        shift
        ;;
        -bi|--base-image)
        BASE_IMAGE_FILE="$2"
        shift
        shift
        ;;
        *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

IMAGE_FILE="${HOST_DIRECTORY}/image.img"
MOUNT_DIRECTORY="${HOST_DIRECTORY}/rootfs"

if [[ -z ${ACTION} ]]; then
  echo "error : [-m|--mount] or [-u|--umount] are required or [-p|--prepare] are required"
  exit 1
fi

if [[ -z ${HOST_DIRECTORY} ]]; then
  echo "error : [-hd|--host-directory <path>] is required"
  exit 1
fi

echo "---- execute action [$ACTION] in ${HOST_DIRECTORY} ----"

set -x -e -o pipefail

function execute_mount() {
  mkdir -p "${MOUNT_DIRECTORY}"
  offset=$(sudo fdisk -l "${IMAGE_FILE}" | grep -A2 -E "Device\s*Boot\s*Start\s*End" | tail -n +2 | sed -r "s/[^ ]* *([0-9]*).*$/\1/")
  offsetInBytes=$((offset * 512))
  local device=$(sudo losetup -f "${IMAGE_FILE}" -o ${offsetInBytes} --show)
  mount -t auto "${device}" "${MOUNT_DIRECTORY}"
  sync
}

function execute_umount() {
  mount | grep "${MOUNT_DIRECTORY}" && umount "${MOUNT_DIRECTORY}" || echo "mount [${MOUNT_DIRECTORY}] missing"
  devices=$(losetup -l -O BACK-FILE,NAME -n -J | jq -r ".loopdevices | .[] | select(.\"back-file\" | contains(\"${IMAGE_FILE}\") ) | .name")
  declare -a arr=(${devices})
  for device in "${arr[@]}"; do
    losetup -d "${device}"
  done
  sync
}

function execute_prepare() {
  if [[ -z ${BASE_IMAGE_FILE} ]]; then
    echo "error : [-bi|--base-image <path>] is required"
    exit 1
  fi
  mkdir -p ${MOUNT_DIRECTORY}
  if [[ ! -f "IMAGE_FILE" ]]; then
    cp "${BASE_IMAGE_FILE}" "${IMAGE_FILE}"
  fi
}

function execute_clean() {
  rm -Rf "${HOST_DIRECTORY}"
}

case ${ACTION} in
    mount)
    execute_umount
    execute_mount
    ;;
    umount)
    execute_umount
    ;;
    prepare)
    execute_umount
    execute_prepare
    execute_mount
    ;;
    clean)
    execute_umount
    execute_clean
    ;;
esac
