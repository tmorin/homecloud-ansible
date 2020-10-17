#!/bin/bash

export CLUSTER="c2"
export homecloud_IP="192.168.11.21"

. $(pwd)/scripts/include.sh

bootstrapVagrant
checkVM 1
checkVM 2
playbook cluster-bootstrap.yml
playbook stacks-deploy.yml

waitForService "traefik" "traefik_server.1"
waitForService "portainer" "portainer_console.1"
waitForService "calibreweb" "calibreweb_server.1"
waitForService "nextcloud" "nextcloud_server.1"
waitForService "nextcloud" "nextcloud_database.1"

waitForLogs "nextcloud_server" "apache2 -D FOREGROUND"

vagrant.sh ${CLUSTER} ssh -c 'docker stack ls --format "{{.Name}} {{.Services}}"' ${CLUSTER}-n1 > /tmp/test
RUNS cat /tmp/test
GREP "backup 1"
GREP "calibreweb 1"
NGREP "influxdata"
GREP "nextcloud 5"
GREP "portainer 2"
GREP "traefik 1"

checkWsFound "calibreweb.homecloud.swarm"
checkWsNotFound "influxdata.homecloud.swarm"
checkWsFound "traefik.homecloud.swarm"
checkWsFound "portainer.homecloud.swarm"
checkWsFound "nextcloud.homecloud.swarm"
