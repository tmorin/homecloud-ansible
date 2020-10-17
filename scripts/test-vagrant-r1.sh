#!/bin/bash

export CLUSTER="r1"
export homecloud_IP="192.168.11.11"

. $(pwd)/scripts/include.sh

bootstrapVagrant
checkVM 1
playbook cluster-bootstrap.yml
playbook stacks-deploy.yml

waitForService "traefik" "traefik_server.1"
waitForService "portainer" "portainer_console.1"
waitForService "backup" "backup_duplicity.1"

vagrant.sh ${CLUSTER} ssh -c 'docker stack ls --format "{{.Name}} {{.Services}}"' ${CLUSTER}-n1 > /tmp/test
RUNS cat /tmp/test
GREP "traefik 1"
GREP "portainer 2"
NGREP "influxdata"
NGREP "calibreweb"
NGREP "nextcloud"
GREP "backup 1"

# remove the existing stacks
vagrant.sh ${CLUSTER} ssh -c 'docker exec $(docker ps --format {{.Names}} | grep duplicity) /tasks/backup-PORTAINER-CONSOLE.sh' ${CLUSTER}-n1
# wait for complete removal
sleep 5

# restore portainer backup
playbook stacks-restore-backup.yml
