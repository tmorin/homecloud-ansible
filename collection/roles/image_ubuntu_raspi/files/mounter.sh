#!/usr/bin/env bash

ACTION=""
HOST_DIRECTORY=""
IMAGE_FILE=""
BASE_IMAGE_FILE=""

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case ${key} in
  -c | --clean)
    ACTION="clean"
    shift
    ;;
  -p | --prepare)
    ACTION="prepare"
    shift
    ;;
  -m | --mount)
    ACTION="mount"
    shift
    ;;
  -u | --umount)
    ACTION="umount"
    shift
    ;;
  -hd | --host-directory)
    HOST_DIRECTORY="$2"
    shift
    shift
    ;;
  -bi | --base-image)
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
MOUNT_BOOTFS_DIRECTORY="${HOST_DIRECTORY}/bootfs"
MOUNT_ROOTFS_DIRECTORY="${HOST_DIRECTORY}/rootfs"

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

  echo "mount ${MOUNT_BOOTFS_DIRECTORY}"
  local offsetStartOne
  local offsetStartOneInBytes
  local offsetEndOne
  local sizeOneInByte
  local deviceOne
  mkdir -p "${MOUNT_BOOTFS_DIRECTORY}"
  offsetStartOne=$(fdisk -l "${IMAGE_FILE}" -o Start | tail -n-2 | head -n+1)
  offsetEndOne=$(fdisk -l "${IMAGE_FILE}" -o End | tail -n-2 | head -n+1)
  offsetStartOneInBytes=$((offsetStartOne * 512))
  sizeOneInByte=$(((offsetEndOne-offsetStartOne) * 512))

  deviceOne=$(losetup -f "${IMAGE_FILE}" -o ${offsetStartOneInBytes} --sizelimit ${sizeOneInByte} --show)
  mount -t auto "${deviceOne}" "${MOUNT_BOOTFS_DIRECTORY}"

  echo "mount ${MOUNT_ROOTFS_DIRECTORY}"
  local offsetStartTwo
  local offsetStartTwoInBytes
  local deviceTwo
  mkdir -p "${MOUNT_ROOTFS_DIRECTORY}"
  offsetStartTwo=$(fdisk -l "${IMAGE_FILE}" -o Start | tail -n-1 | head -n+1)
  offsetStartTwoInBytes=$((offsetStartTwo * 512))
  deviceTwo=$(losetup -f "${IMAGE_FILE}" -o ${offsetStartTwoInBytes} --show)
  mount -t auto "${deviceTwo}" "${MOUNT_ROOTFS_DIRECTORY}"

  sync
}

function execute_umount() {
  mount | grep "${MOUNT_BOOTFS_DIRECTORY}" && umount "${MOUNT_BOOTFS_DIRECTORY}" || echo "mount [${MOUNT_BOOTFS_DIRECTORY}] missing"
  mount | grep "${MOUNT_ROOTFS_DIRECTORY}" && umount "${MOUNT_ROOTFS_DIRECTORY}" || echo "mount [${MOUNT_ROOTFS_DIRECTORY}] missing"

  devices=$(losetup -l -O BACK-FILE,NAME -n -J | jq -r ".loopdevices | .[] | select(.\"back-file\" | contains(\"${IMAGE_FILE}\") ) | .name")
  declare -a arr=(${devices})
  for deviceOne in "${arr[@]}"; do
    losetup -d "${deviceOne}"
  done

  sync
}

function execute_prepare() {
  if [[ -z ${BASE_IMAGE_FILE} ]]; then
    echo "error : [-bi|--base-image <path>] is required"
    exit 1
  fi
  mkdir -p "${HOST_DIRECTORY}"
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
