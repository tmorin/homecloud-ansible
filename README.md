# homecloud

> `homecloud` provides a ready-to-use set of resources to bootstrap a cloud at home based on Docker Swarm, Ceph and Syncthing.

## Overview

This ansible collection provides the following building blocks:

- a Docker Swarm with:
    - a layer4 load-balancer handled by `keepalived`
    - a modern reverse proxy for UDP, TCP and HTTP handled by `traefik`
- a distributed file system handled by `ceph`
- a decentralized solution to synchronize files between local/remote nodes with `Syncthing`

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

The collection's roles can be dependent of the following ansible collection:
```shell script
ansible-galaxy collection install community.general
ansible-galaxy install dev-sec.os-hardening --force
ansible-galaxy install dev-sec.ssh-hardening --force
```

To build the Armbian images, the following dependencies are required:
```shell script
apt-get install jq qemu-system-arm qemu-user-static
```

## Inventory

The following inventory define a cluster of six nodes.

All of them are parts of the Docker Swarm.
The first three ones are managers of the swarm whereas the remaining ones are simple workers.

The Ceph setup use the six nodes as well.
The first three nodes host the mon and mgr of the Ceph cluster whereas the last three nodes host the osd.

Finally, the "decentralized" NAS uses the last to nodes.

```yaml
all:
  children:
    # BOARDS
    rock64:
      hosts:
        node1:
        node2:
        node3:
        node4:
        node5:
        node6:
    # SWARM
    swarm_mgr:
      hosts:
        node1:
        node2:
        node3:
    swarm_wkr:
      hosts:
        node4:
        node5:
        node6:
    swarm:
      children:
        swarm_mgr:
        swarm_wkr:
    # CEPH
    ceph_mon:
      hosts:
        node1:
        node2:
        node3:
    ceph_mgr:
      hosts:
        node1:
        node2:
        node3:
    ceph_osd:
      hosts:
        node4:
        node5:
        node6:
    ceph:
      children:
        ceph_mon:
        ceph_mgr:
        ceph_osd:
    # CEPH
    dnas:
      hosts:
        node5:
        node6:
```

## Ansible Roles

The collection provides several roles.

Roles configuring hosts' system:

- `cluster_node`: apply basic configurations (hostname, deactivate the swap ...)

Roles installing ready-to-use services:

- `service_docker`: install and configure Docker
- `service_swarm`: install and configure Docker Swarm
- `service_ceph`: install and configure a Ceph cluster with cephadm
- `service_keepalived`: install and configure Keepalived with Docker container
- `service_dnas`: install and configure Samba and syncthing

Roles deploying ready-to-use Docker Swarm stacks:

- `stack_traefik`: deploy a Docker Swarm stack running Traefik
- `stack_portainer`: deploy a Docker Swarm stack running Portainer
- `stack_influxdata`: deploy a Docker Swarm stack based on influxdata products (Influxdb, Telegraf, Kapacitor, Chronograf)
- `stack_calibreweb`: deploy a Docker Swarm stack running Calibreweb
- `stack_nextcloud`: deploy a Docker Swarm stack running Nextcloud
- `stack_backup`: deploy a Docker Swarm stack running Duplicity in order to backup Docker volumes

## Ansible Playbooks

### Bootstrap the cluster

The playbook [cluster-bootstrap.yml](playbooks/cluster-bootstrap.yml) bootstraps the cluster, i.e. the Docker Swarm instance, the Ceph cluster, and the Decentralized NAS.

### Deploy the stacks

The playbook [stacks-deploy.yml](playbooks/stacks-deploy.yml) deploys the stacks.

### Restore stacks backups

The playbook [stacks-restore-backups.yml](playbooks/stacks-restore-backup.yml) restores backups of stacks.

## Examples

Several examples are available in the [inventories](./inventories) directory.

| |[vagrant-c1]|[vagrant-c2]|[vagrant-c3]|[vagrant-c4]|[vagrant-r1]|[vagrant-d1]|
|---|---|---|---|---|---|---|
|nodes|1|2|3|4|1|1|
|https|no|no|no|no|no|no|
|keepalived|no|yes|yes|yes|no|no|
|ceph|no|yes|yes|yes|no|no|
|portainer|yes|yes|yes|yes|yes|no|
|influxdata|yes|no|no|yes|no|no|
|nextcloud|yes|yes|yes|yes|no|no|
|calibreweb|yes|yes|yes|yes|no|no|
|backup|yes|yes|yes|yes|yes|no|
|restore|no|no|no|no|yes|no|
|dans|no|no|no|yes|no|yes|

[vagrant-c1]: inventories/vagrant-c1/README.md
[vagrant-c2]: inventories/vagrant-c2/README.md
[vagrant-c3]: inventories/vagrant-c3/README.md
[vagrant-c4]: inventories/vagrant-c4/README.md
[vagrant-r1]: inventories/vagrant-r1/README.md
[vagrant-d1]: inventories/vagrant-d1/README.md

## Development

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
