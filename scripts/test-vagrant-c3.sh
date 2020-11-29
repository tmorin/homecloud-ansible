#!/bin/bash

export CLUSTER="c3"
export HOMECLOUD_IP="192.168.11.31"

. $(pwd)/scripts/include.sh

bootstrapVagrant
checkVM 1
checkVM 2
checkVM 3
playbook cluster-hardening.yml
playbook cluster-bootstrap.yml
playbook stacks-deploy.yml

echo "--- check swarm services"
waitForService "traefik" "traefik_server.1"
waitForService "portainer" "portainer_console.1"
waitForService "calibreweb" "calibreweb_server.1"
waitForService "backup" "backup_duplicity.1"
waitForService "nextcloud" "nextcloud_server.1"
waitForService "nextcloud" "nextcloud_database.1"

waitForLogs "traefik_server" "Configuration loaded from flags."
waitForLogs "portainer_console" "server: Listening on 0.0.0.0:8000"
waitForLogs "backup_duplicity" "INFO:setup-cron:process backup-CALIBREWEB-CONFIG"
waitForLogs "nextcloud_server" "apache2 -D FOREGROUND"

echo "--- check swarm stacks"
vagrant.sh ${CLUSTER} ssh -c 'docker stack ls --format "{{.Name}} {{.Services}}" || true' ${CLUSTER}-n1 &>/tmp/test
RUNS cat /tmp/test
GREP "backup 1"
GREP "calibreweb 1"
GREP "nextcloud 5"
GREP "portainer 2"
GREP "traefik 1"

echo "--- check web services"
checkWsFound "calibreweb.homecloud.swarm"
checkWsFound "nextcloud.homecloud.swarm"
checkWsFound "portainer.homecloud.swarm"
checkWsFound "traefik.homecloud.swarm"

echo "--- check syncthing"
vagrant.sh ${CLUSTER} ssh -c 'systemctl status syncthing@dnas.service || true' ${CLUSTER}-n3 &>/tmp/test_syncthing
RUNS cat /tmp/test_syncthing
GREP "syncthing@dnas.service"
GREP "active (running)"

echo "--- add /data/test_file in calibreweb_config"
calibreweb_server_node=$(getServiceNode calibreweb_server)
OK -n "$calibreweb_server_node"
vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v calibreweb_config:/data busybox touch /data/test_file' "$calibreweb_server_node"
IS "$?" == "0"
vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v calibreweb_config:/data busybox ls -l /data/test_file' "$calibreweb_server_node" >/tmp/test-test_file
IS "$?" == "0"
RUNS cat /tmp/test-test_file
GREP "/data/test_file"

echo "--- force backup_duplicity backup"
backup_duplicity_node=$(getServiceNode backup_duplicity)
OK -n "$backup_duplicity_node"
vagrant.sh ${CLUSTER} ssh -c 'docker exec $(docker ps --filter name=backup_duplicity --format {{.Names}}) /tasks/backup-CALIBREWEB-CONFIG.sh' "$backup_duplicity_node"
IS "$?" == "0"

echo "--- remove /data/test_file from calibreweb_config"
vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v calibreweb_config:/data busybox rm /data/test_file' "$calibreweb_server_node"
IS "$?" == "0"
vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v calibreweb_config:/data busybox ls /data' "$calibreweb_server_node"
IS "$?" == "0"

echo "--- restore calibreweb_config"
playbook stacks-restore-backup.yml

vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v calibreweb_config:/data busybox ls -l /data/test_file' "$calibreweb_server_node" >/tmp/test-test_file
IS "$?" == "0"
RUNS cat /tmp/test-test_file
GREP "/data/test_file"
