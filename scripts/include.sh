#!/usr/bin/env bash

PATH=$(pwd)/scripts:${PATH}
export PATH

set -euo pipefail

# https://github.com/coryb/osht
eval "$(curl -q -s https://raw.githubusercontent.com/coryb/osht/master/osht.sh)"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case ${key} in
  --cluster=*)
    export CLUSTER="${key#*=}"
    ;;
  --swarm-ip=*)
    export homecloud_IP="${key#*=}"
    ;;
  *)
    POSITIONAL+=("$1")
    ;;
  esac
  shift
done
set -- "${POSITIONAL[@]}"

if [[ -z "${CLUSTER}" ]]; then
  echo "--cluster is required"
  exit 1
fi

if [[ -z "${homecloud_IP}" ]]; then
  echo "--swarm-ip! -z is required"
  exit 2
fi

function bootstrapVagrant() {
  vagrant.sh "${CLUSTER}" destroy --force || exit 1
  IS "$?" == "0"
  echo "sleep for 5 seconds" && sleep 5

  vagrant.sh "${CLUSTER}" up || exit 1
  IS "$?" == "0"
  echo "sleep for 5 seconds" && sleep 5
}

function checkVM() {
  local nbr="$1"
  OK -n "$nbr"
  vagrant.sh "${CLUSTER}" ssh -c "hostname" "${CLUSTER}-n${nbr}"
  IS "$?" == "0"
}

function playbook() {
  local book=$1
  ansible-playbook -i "inventories/vagrant-${CLUSTER}/inventory.yml" "playbooks/${book}"
  IS "$?" == "0"
}

function checkWsFound() {
  set -eo pipefail
  local host=$1
  echo checkWsFound "${host}"
  OK -n "$host"
  curl -sILH "host:${host}" "http://${homecloud_IP}" | head -n 1 || true &>/tmp/ws_result
  IS "$?" == "0"
  RUNS cat /tmp/ws_result
  NGREP "HTTP/1.1 404 Not Found"
}

function checkWsNotFound() {
  local host=$1
  echo checkWsNotFound "${host}"
  OK -n "$host"
  curl -sILH "host:${host}" "http://${homecloud_IP}" | head -n 1 || true &>/tmp/ws_result
  IS "$?" == "0"
  RUNS cat /tmp/ws_result
  GREP "HTTP/1.1 404 Not Found"
}

function waitForService() {
  local stack="$1"
  OK -n "$stack"
  local service="$2"
  OK -n "$service"
  until [[ -n "$(grep -Eo "${service} Running" /tmp/test)" ]]; do
    echo "wait for the ${service} service" && sleep 1
    local command="docker stack ps ${stack} --format='{{.Name}} {{.CurrentState}}'"
    vagrant.sh "${CLUSTER}" ssh -c "${command}" "${CLUSTER}-n1" &>/tmp/test
  done
}

function waitForLogs() {
  local service="$1"
  OK -n "$service"
  local entry="$2"
  OK -n "$entry"
  until [[ -n "$(grep -Eo "${entry}" /tmp/test)" ]]; do
    echo "wait for the ${service} logs" && sleep 1
    local command="docker service logs ${service}"
    vagrant.sh "${CLUSTER}" ssh -c "${command}" "${CLUSTER}-n1" &>/tmp/test
  done
}
