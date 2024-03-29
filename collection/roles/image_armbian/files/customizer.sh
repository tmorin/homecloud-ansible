#!/usr/bin/env bash

ROOT_FS=""
CREATE_USER="homecloud"
LOCK_ROOT="yes"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case ${key} in
  -rf | --root-fs)
    ROOT_FS="$2"
    shift
    shift
    ;;
  -cu | --change-username)
    CREATE_USER="$2"
    shift
    shift
    ;;
  -dcu | --disable-create-user)
    CREATE_USER=""
    shift
    ;;
  -dlr | --disable-lock-root)
    LOCK_ROOT="no"
    shift
    ;;
  *)
    POSITIONAL+=("$1")
    shift
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -z "${ROOT_FS}" ]]; then
  echo "error : [-rf|--root-fs <path>] is required"
  exit 1
fi

if [[ -n "${CREATE_USER}" ]]; then
  chroot "${ROOT_FS}" /bin/bash -exc "
echo create the user ${CREATE_USER}
# create the user with the password disabled
useradd -m -d /home/${CREATE_USER} -s /bin/bash ${CREATE_USER}
# prepare the .ssh directory
mkdir -p /home/${CREATE_USER}/.ssh
touch /home/${CREATE_USER}/.ssh/authorized_keys
chown -R ${CREATE_USER}:${CREATE_USER} /home/${CREATE_USER}
chmod 700 /home/${CREATE_USER}/.ssh
chmod 600 /home/${CREATE_USER}/.ssh/authorized_keys
# add the user to sudoers people without password
echo \"${CREATE_USER} ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers.d/${CREATE_USER}
chmod 0440 /etc/sudoers.d/${CREATE_USER}"
fi

if [[ "${LOCK_ROOT}" == "yes" ]]; then
  chroot "${ROOT_FS}" /bin/bash -exc "
usermod --lock root
passwd -l root
chage -d $(date "+%F") -E 2999-01-01 -I -1 -m 0 -M 999999 -W 31 root"
fi
