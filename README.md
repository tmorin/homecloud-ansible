# homecloud - swarm

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
- Memory: at least 2 GO

If `ceph` is enabled:

- 1 available storage device by hosts ([more information there](https://docs.ceph.com/docs/master/cephadm/install/#deploy-osds))

## Ansible Roles

The collection provides several roles.

Roles configuring hosts' system:

- `cluster_node`: apply basic configurations (hostname, deactivate swap ...)

Roles installing ready-to-use services:

- `service_docker`: install and configure Docker
- `service_swarm`: install and configure Docker Swarm
- `service_ceph`: install and configure a Ceph cluster with cephadm
- `service_keepalived`: install and configure Keepalived with Docker container
- `service_syncthing`: install and configure Synchting

Roles deploying ready-to-use Docker Swarm stacks:

- `stack_traefik`: deploy a Docker Swarm stack propulsing Traefik
- `stack_portainer`: deploy a Docker Swarm stack propulsing Portainer
- `stack_influxdata`: deploy a Docker Swarm stack based on influxdata products (Influxdb, Telegraf, Kapacitor, Chronograf)
- `stack_calibreweb`: deploy a Docker Swarm stack propulsing Calibreweb
- `stack_nextcloud`: deploy a Docker Swarm stack propulsing Nextcloud
- `stack_backup`: deploy a Docker Swarm stack propulsing Duplicity to backup Docker volumes

## Ansible Playbooks

### Bootstrap the Docker Swarm

The playbook [swarm-bootstrap.yml](./swarm-bootstrap.yml) bootstraps a cluster of Docker Swarm instances.

The playbook depends on some [Ansible Galaxy](https://galaxy.ansible.com) dependencies:

- https://galaxy.ansible.com/dev-sec/os-hardening
- https://galaxy.ansible.com/dev-sec/ssh-hardening

```bash
ansible-galaxy install dev-sec.os-hardening dev-sec.ssh-hardening
```

The playbook executes the roles listed in the variable `homecloud_services`.

### Deploy the stacks

The playbook [stacks-deploy.yml](./stacks-deploy.yml) deploys the stacks.

The playbook executes the roles listed in the variable `homecloud_stacks`.

### Restore stacks backups

The playbook [stacks-restore-backups.yml](./stacks-restore-backup.yml) restores backups of stacks.

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
|nextcloud|yes|yes|yes|
|calibreweb|yes|yes|yes|
|backup|yes|yes|yes|

[vagrant-c1]: inventories/vagrant-c1/README.md
[vagrant-c2]: inventories/vagrant-c2/README.md
[vagrant-c3]: inventories/vagrant-c3/README.md

## Ansible Galaxy dependencies

- https://galaxy.ansible.com/dev-sec/os-hardening
- https://galaxy.ansible.com/dev-sec/ssh-hardening

```bash
ansible-galaxy install dev-sec.os-hardening dev-sec.ssh-hardening
```
