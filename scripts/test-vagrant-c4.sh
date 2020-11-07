#!/bin/bash

export CLUSTER="c4"
export homecloud_IP="192.168.11.41"

. $(pwd)/scripts/include.sh

bootstrapVagrant
checkVM 1
checkVM 2
checkVM 3
checkVM 4
playbook cluster-hardening.yml
playbook cluster-bootstrap.yml
playbook stacks-deploy.yml

waitForService "traefik" "traefik_server.1"
waitForService "portainer" "portainer_console.1"
waitForService "influxdata" "influxdata_influxdb.1"
waitForService "influxdata" "influxdata_chronograf.1"
waitForService "calibreweb" "calibreweb_server.1"
waitForService "nextcloud" "nextcloud_server.1"
waitForService "nextcloud" "nextcloud_database.1"

waitForLogs "nextcloud_server" "apache2 -D FOREGROUND"

vagrant.sh ${CLUSTER} ssh -c 'docker stack ls --format "{{.Name}} {{.Services}}"' ${CLUSTER}-n1 > /tmp/test
RUNS cat /tmp/test
GREP "backup 1"
GREP "calibreweb 1"
GREP "influxdata 4"
GREP "nextcloud 5"
GREP "portainer 2"
GREP "traefik 1"

checkWsFound "influxdata.homecloud.swarm"
checkWsFound "traefik.homecloud.swarm"
checkWsFound "portainer.homecloud.swarm"
checkWsFound "nextcloud.homecloud.swarm"
checkWsFound "calibreweb.homecloud.swarm"