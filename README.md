# homecloud

> `homecloud` provides a ready-to-use set of resources to bootstrap a cloud at home based on Docker Swarm.

## Overview

This ansible collection provides the following building blocks:

- a layer4 load-balancer handled by `keepalived`
- a distributed file system handled by `ceph`
- a modern reverse proxy for UDP, TCP and HTTP handled by `traefik`

The collection provides also ready-to-use stacks:

- `influxdata`: a set of components to monitor the Docker Swarm.
- `portainer`: a lightweight management UI to easily manage the Docker Swarm.
- `nextcloud`: a platform providing the benefits of online collaboration without the compliance and security risks.
- `calibreweb`:  a web app providing a clean interface for browsing, reading and downloading eBooks using an existing Calibre database.
- `backup`: a system based on Duplicity and CRON which backups Docker volumes. 

Additionally, Armbian images can be created for each host of the inventory.

## Requirements

Each hosts must fulfilled the following constraints:

- Operating System: Debian Stretch or Debian Buster
- CPU Architecture: amd64 or arm64
- Memory: at least 2Go

If `ceph` is enabled:

- 1 available storage device by hosts ([more information there](https://docs.ceph.com/docs/master/cephadm/install/#deploy-osds))

## Dependencies

```shell script
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

## Ansible Roles

The collection provides several roles.

Roles configuring hosts' system:

- `cluster_node`: apply basic configurations (hostname, deactivate swap ...)

Roles installing ready-to-use services:

- `service_docker`: install and configure Docker
- `service_swarm`: install and configure Docker Swarm
- `service_ceph`: install and configure a Ceph cluster with cephadm
- `service_keepalived`: install and configure Keepalived with Docker container
- `service_nas`: install and configure Samba and syncthing

Roles deploying ready-to-use Docker Swarm stacks:

- `stack_traefik`: deploy a Docker Swarm stack running Traefik
- `stack_portainer`: deploy a Docker Swarm stack running Portainer
- `stack_influxdata`: deploy a Docker Swarm stack based on influxdata products (Influxdb, Telegraf, Kapacitor, Chronograf)
- `stack_calibreweb`: deploy a Docker Swarm stack running Calibreweb
- `stack_nextcloud`: deploy a Docker Swarm stack running Nextcloud
- `stack_backup`: deploy a Docker Swarm stack running Duplicity in order to backup Docker volumes

## Ansible Playbooks

### Bootstrap the Docker Swarm

The playbook [swarm-bootstrap.yml](playbooks/swarm-bootstrap.yml) bootstraps a cluster of Docker Swarm instances.

The playbook executes the roles listed in the variable `homecloud_services`.

### Deploy the stacks

The playbook [stacks-deploy.yml](playbooks/stacks-deploy.yml) deploys the stacks.

The playbook executes the roles listed in the variable `homecloud_stacks`.

### Restore stacks backups

The playbook [stacks-restore-backups.yml](playbooks/stacks-restore-backup.yml) restores backups of stacks.

## Examples

Several examples are available in the [inventories](./inventories) directory.

| |[vagrant-c1]|[vagrant-c2]|[vagrant-c3]|[vagrant-r1]|
|---|---|---|---|---|
|nodes|1|2|3|1|
|https|no|no|no|no|
|keepalived|no|yes|yes|no|
|ceph|no|yes|yes|no|
|portainer|yes|yes|yes|yes|
|influxdata|yes|no|no|no|
|nextcloud|yes|yes|yes|no|
|calibreweb|yes|yes|yes|no|
|backup|yes|yes|yes|yes|
|restore|no|no|no|yes|

[vagrant-c1]: inventories/vagrant-c1/README.md
[vagrant-c2]: inventories/vagrant-c2/README.md
[vagrant-c3]: inventories/vagrant-c3/README.md
[vagrant-r1]: inventories/vagrant-r1/README.md

# Development

Install Vagrant
```shell script
apt-get --yes build-dep vagrant ruby-libvirt
vagrant plugin install vagrant-libvirt
```

Install libvirt
```shell script
apt-get --yes install qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
```

Install python3
```shell script
apt-get --yes install python-virtualenv python3-dev
```

Setup dev/test environment
```shell script
virtualenv -p python3 venv
source venv/bin/activate
python3 -m pip install --upgrade --ignore-installed --requirement requirements.txt
```

Execute test
```shell script
molecule test -s swarm_single_node
```
