#!/usr/bin/env bash

pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}";
if [ -h "$SCRIPT_PATH" ]; then
  while [ -h "$SCRIPT_PATH" ] ; do cd "$(dirname "$SCRIPT_PATH")"; SCRIPT_PATH=$(readlink "$SCRIPT_PATH"); done
fi
cd "$(dirname "$SCRIPT_PATH")" > /dev/null
SCRIPT_PATH="$(pwd)";
popd  > /dev/null

VAGRANT_DEFAULT_PROVIDER="${VAGRANT_DEFAULT_PROVIDER:=libvirt}"
export VAGRANT_DEFAULT_PROVIDER="libvirt"

PATH=$SCRIPT_PATH:${PATH}
export PATH

set -u

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
    export HOMECLOUD_IP="${key#*=}"
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

if [[ -z "${HOMECLOUD_IP}" ]]; then
  echo "--swarm-ip is required"
  exit 2
fi

if [[ -n "${DOCKER_USERNAME}" ]]; then
  echo "{ \"service_docker_username\":\"$DOCKER_USERNAME\", \"service_docker_password\":\"$DOCKER_PASSWORD\" }" >tmp/extra-vars.json
else
  echo "{}" >tmp/extra-vars.json
fi

function bootstrapVagrant() {
  vagrant.sh "${CLUSTER}" destroy --force
  IS "$?" == "0"
  echo "sleep for 5 seconds" && sleep 5

  vagrant.sh "${CLUSTER}" up
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
  ansible-playbook \
    --extra-vars "@tmp/extra-vars.json" \
    -i "inventories/vagrant-${CLUSTER}/inventory.yml" \
    "playbooks/${book}"
  IS "$?" == "0"
}

function checkWsFound() {
  local host=$1
  echo checkWsFound "${host}"
  OK -n "$host"
  echo '' >/tmp/ws_result
  curl -sILH "host:${host}" "http://${HOMECLOUD_IP}" &>/tmp/ws_result || true
  IS "$?" == "0"
  RUNS cat /tmp/ws_result
  NGREP "HTTP/1.1 404 Not Found"
}

function checkWsNotFound() {
  local host=$1
  echo checkWsNotFound "${host}"
  OK -n "$host"
  echo '' >/tmp/ws_result
  curl -sILH "host:${host}" "http://${HOMECLOUD_IP}" &>/tmp/ws_result || true
  IS "$?" == "0"
  RUNS cat /tmp/ws_result
  GREP "HTTP/1.1 404 Not Found"
}

function waitForService() {
  local stack="$1"
  OK -n "$stack"
  local service="$2"
  OK -n "$service"
  echo '' >/tmp/test_service
  until [[ -n "$(grep -Eo "${service} Running" /tmp/test_service)" ]]; do
    echo "wait for the ${service} service" && sleep 1
    local command="docker stack ps ${stack} --format='{{.Name}} {{.CurrentState}}' || true"
    vagrant.sh "${CLUSTER}" ssh -c "${command}" "${CLUSTER}-n1" &>/tmp/test_service
  done
}

function waitForLogs() {
  local service="$1"
  OK -n "$service"
  local entry="$2"
  OK -n "$entry"
  echo '' >/tmp/test_logs
  until [[ -n "$(grep -Eo "${entry}" /tmp/test_logs)" ]]; do
    echo "wait for the ${service} logs" && sleep 1
    local command="docker service logs ${service} || true"
    vagrant.sh "${CLUSTER}" ssh -c "${command}" "${CLUSTER}-n1" &>/tmp/test_logs
  done
}

function getServiceNode() {
  local service="$1"
  local command="docker service ps $service --filter desired-state=running --format '{{.Node}}'|| true"
  vagrant.sh "${CLUSTER}" ssh -c "${command}" "${CLUSTER}-n1" &>/tmp/test_service || true
  grep -oP '(c[0-9]-n[0-9])' /tmp/test_service || echo ''
}
