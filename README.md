# homecloud

[![Build Status](https://travis-ci.org/tmorin/homecloud-ansible.svg?branch=master)](https://travis-ci.org/tmorin/homecloud-ansible)

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
ansible-galaxy collection install -r requirements.yml
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

### Hardening

The playbook [cluster-hardening.yml](playbooks/cluster-hardening.yml) apply hardening recommendations on the operating system and SSH.
The activities are managed by the Ansible collection [devsec.hardening].

[dev-sec.os-hardening]: https://galaxy.ansible.com/devsec/hardening

### Bootstrap the cluster

The playbook [cluster-bootstrap.yml](playbooks/cluster-bootstrap.yml) bootstraps the cluster, i.e. the Docker Swarm instance, the Ceph cluster, and the Decentralized NAS.

### Deploy the stacks

The playbook [stacks-deploy.yml](playbooks/stacks-deploy.yml) deploys the stacks.

### Restore stacks backups

The playbook [stacks-restore-backups.yml](playbooks/stacks-restore-backup.yml) restores backups of stacks.

## Examples

Several examples are available in the [inventories](./inventories) directory.

| |[vagrant-c1]|[vagrant-c2]|[vagrant-c3]|
|---|---|---|---|
|nodes|1|2|3|
|https|no|no|no|
|keepalived|no|yes|yes|
|ceph|no|yes|yes|
|portainer|yes|yes|yes|
|influxdata|yes|no|no|
|nextcloud|yes|no|yes|
|calibreweb|yes|no|yes|
|backup|yes|yes|yes|
|restore|no|yes|yes|
|dans|no|yes|yes|

The examples rely on [vagrant] and [vagrant-libvirt].

[vagrant-c1]: inventories/vagrant-c1/README.md
[vagrant-c2]: inventories/vagrant-c2/README.md
[vagrant-c3]: inventories/vagrant-c3/README.md
[vagrant]: https://www.vagrantup.com/
[vagrant-libvirt]: https://github.com/vagrant-libvirt/vagrant-libvirt
