#!/bin/bash

pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}";
if [ -h "$SCRIPT_PATH" ]; then
  while [ -h "$SCRIPT_PATH" ] ; do cd "$(dirname "$SCRIPT_PATH")"; SCRIPT_PATH=$(readlink "$SCRIPT_PATH"); done
fi
cd "$(dirname "$SCRIPT_PATH")" > /dev/null
SCRIPT_PATH="$(pwd)";
popd  > /dev/null

export CLUSTER="c2"
export HOMECLOUD_IP="192.168.11.21"

source "$SCRIPT_PATH/include.sh"

bootstrapVagrant
checkVM 1
checkVM 2
playbook cluster-hardening.yml
playbook cluster-bootstrap.yml
playbook stacks-deploy.yml

echo "--- check swarm stacks"
vagrant.sh ${CLUSTER} ssh -c 'docker stack ls --format "{{.Name}} {{.Services}}"' ${CLUSTER}-n1 &>/tmp/test || true
IS "$?" == "0"
RUNS cat /tmp/test
GREP "traefik 1"
GREP "portainer 2"
GREP "backup 1"

echo "--- check swarm services"
waitForService "traefik" "traefik_server.1"
waitForService "portainer" "portainer_console.1"
waitForService "backup" "backup_duplicity.1"

echo "--- check swarm service logs"
waitForLogs "traefik_server" "Configuration loaded from flags."
waitForLogs "portainer_console" "server: Listening on 0.0.0.0:8000"
waitForLogs "backup_duplicity" "INFO:setup-cron:process backup-PORTAINER-CONSOLE"

echo "--- check web services"
checkWsFound "traefik.homecloud.swarm"
checkWsFound "portainer.homecloud.swarm"

#echo "--- check syncthing"
#vagrant.sh ${CLUSTER} ssh -c 'systemctl status syncthing@dnas.service || true' ${CLUSTER}-n1 &>/tmp/test_syncthing
#RUNS cat /tmp/test_syncthing
#GREP "syncthing@dnas.service"
#GREP "active (running)"

echo "--- add /data/test_file in portainer_console"
portainer_console_node=$(getServiceNode portainer_console)
OK -n "$portainer_console_node"
vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v portainer_console:/data busybox touch /data/test_file' "$portainer_console_node"
IS "$?" == "0"

echo "--- force backup_duplicity backup"
backup_duplicity_node=$(getServiceNode backup_duplicity)
OK -n "$backup_duplicity_node"
vagrant.sh ${CLUSTER} ssh -c 'docker exec $(docker ps --filter name=backup_duplicity --format {{.Names}}) /tasks/backup-PORTAINER-CONSOLE.sh' "$backup_duplicity_node"
IS "$?" == "0"

echo "--- remove /data/test_file from calibreweb_config"
vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v portainer_console:/data busybox rm /data/test_file' "$portainer_console_node"
IS "$?" == "0"

echo "--- restore portainer_console"
playbook stacks-restore-backup.yml

vagrant.sh ${CLUSTER} ssh -c 'docker run --rm -v portainer_console:/data busybox ls -l /data/test_file' "$portainer_console_node" &>/tmp/test-test_file
IS "$?" == "0"
RUNS cat /tmp/test-test_file
GREP "/data/test_file"
