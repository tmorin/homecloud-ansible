#!/bin/bash

pushd . >/dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -h "$SCRIPT_PATH" ]; then
  while [ -h "$SCRIPT_PATH" ]; do
    cd "$(dirname "$SCRIPT_PATH")" && SCRIPT_PATH=$(readlink "$SCRIPT_PATH")
  done
fi
cd "$(dirname "$SCRIPT_PATH")" >/dev/null && SCRIPT_PATH="$(pwd)"
popd >/dev/null || true

export CLUSTER="c1"
export HOMECLOUD_IP="192.168.11.10"

source "$SCRIPT_PATH/include.sh"

bootstrapVagrant
checkVM 1
playbook cluster-hardening.yml
playbook cluster-bootstrap.yml
playbook stacks-deploy.yml

waitForService "traefik" "traefik_server.1"
waitForService "portainer" "portainer_console.1"
waitForService "influxdata" "influxdata_influxdb.1"
waitForService "influxdata" "influxdata_chronograf.1"
waitForService "calibreweb" "calibreweb_server.1"
waitForService "backup" "backup_duplicity.1"
waitForService "nextcloud" "nextcloud_server.1"
waitForService "nextcloud" "nextcloud_database.1"

waitForLogs "traefik_server" "Configuration loaded from flags."
waitForLogs "portainer_console" "server: Listening on 0.0.0.0:8000"
waitForLogs "backup_duplicity" "INFO:setup-cron:process backup-PORTAINER-CONSOLE"
waitForLogs "nextcloud_server" "apache2 -D FOREGROUND"

vagrant.sh ${CLUSTER} ssh -c 'docker stack ls --format "{{.Name}} {{.Services}}"' ${CLUSTER}-n1 &>/tmp/test
IS "$?" == "0"
RUNS cat /tmp/test
GREP "backup 1"
GREP "calibreweb 1"
GREP "influxdata 4"
GREP "nextcloud 5"
GREP "portainer 2"
GREP "traefik 1"

checkWsFound "calibreweb.homecloud.swarm"
checkWsFound "influxdata.homecloud.swarm"
checkWsFound "traefik.homecloud.swarm"
checkWsFound "portainer.homecloud.swarm"
checkWsFound "nextcloud.homecloud.swarm"
