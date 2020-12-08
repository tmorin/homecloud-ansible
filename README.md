# homecloud-ansible

[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/tmorin/homecloud-ansible/Continous%20Integration/master?label=GitHub%20Actions&logo=github+actions&logoColor=black)](https://github.com/tmorin/homecloud-ansible/actions?query=workflow%3A%22Continous+Integration%22+branch%3Amaster)
[![Travis (.org) branch](https://img.shields.io/travis/tmorin/homecloud-ansible/master?label=Travis%20CI&logo=travis+CI&logoColor=black)](https://travis-ci.org/github/tmorin/homecloud-ansible)

> `homecloud` provides a ready-to-use set of resources to bootstrap a cloud at home based on Docker Swarm, Ceph and Syncthing.

## Presentation

`homecloud` aims to provide a cloud like environment, especially an internal cloud, at home.
The underlying infrastructure is primarily based on low cost ARM boards, like Raspberry Pi, and powered by open source solutions like Docker Swarm, Ceph or Syncthing.

The main artifact is an Ansible collection designed to bootstrap a ready to use cloud like environment as well as a couple of end-users services.

An in-depth explanation is available in the [paper](./paper/README.adoc).

## Overview

This ansible collection provides the following building blocks:

- a Docker Swarm with:
  - a layer4 load-balancer handled by `keepalived`
  - a modern reverse proxy for UDP, TCP and HTTP handled by `traefik`
- a distributed file system handled by `ceph`
- a decentralized solution to synchronize files between local/remote nodes with `Syncthing`

The collection provides also ready-to-use stacks:

- `influxdata` : a set of components to monitor the Docker Swarm.
- `portainer` : a lightweight management UI to easily manage the Docker Swarm.
- `nextcloud` : a platform providing the benefits of online collaboration without the compliance and security risks.
- `calibreweb` :  a web app providing a clean interface for browsing, reading and downloading eBooks using an existing Calibre database.
- `backup` : a system based on Duplicity and CRON which backups Docker volumes. 

Additionally, Armbian images can be created for each host of the inventory.

## Requirements

Each hosts must fulfilled the following constraints:

- Operating System: Ubuntu > 18.4 and Debian > Stretch
- CPU Architecture: amd64 or arm64
- Memory: at least 2Go

If `ceph` is enabled:

- 1 available storage block device by hosts ([more information there](https://docs.ceph.com/docs/master/cephadm/install/#deploy-osds))

## Dependencies

The collection dependencies are bundled in [./requirements.yml](./requirements.yml).
```shell script
ansible-galaxy collection install -r requirements.yml
```

In order to build the custom Armbian images, additional dependencies are required:
```shell script
apt-get install jq qemu-system-arm qemu-user-static
```

## Inventory

The following inventory define a cluster of five nodes.

All of them are parts of the Docker Swarm.
The first three ones are managers of the swarm whereas the remaining ones are simple workers.
The Ceph setup use the first three nodes.
Finally, the "decentralized" NAS uses the last two nodes.

```yaml
all:
  children:
    # BOARDS
    rock64:
      hosts:
        n1:
        n2:
        n3:
    pine64:
      host:
        n4:
        n5:
    # SWARM
    swarm_mgr:
      hosts:
        n1:
        n2:
        n3:
    swarm_wkr:
      hosts:
        n4:
        n5:
    swarm:
      children:
        swarm_mgr:
        swarm_wkr:
    # CEPH
    ceph_mon:
      hosts:
        n1:
        n2:
        n3:
    ceph_mgr:
      hosts:
        n1:
        n2:
        n3:
    ceph_osd:
      hosts:
        n1:
        n2:
        n3:
    ceph:
      children:
        ceph_mon:
        ceph_mgr:
        ceph_osd:
    # CEPH
    dnas:
      hosts:
        n4:
        n5:
```

## Ansible Playbooks

### Hardening

The playbook [playbooks/cluster-hardening.yml](playbooks/cluster-hardening.yml) apply hardening recommendations on the operating system and SSH.
The activities are managed by the Ansible collection [devsec.hardening].

[devsec.hardening]: https://galaxy.ansible.com/devsec/hardening

### Bootstrap the cluster

The playbook [playbooks/cluster-bootstrap.yml](playbooks/cluster-bootstrap.yml) bootstraps the cluster, i.e. the Docker Swarm instance, the Ceph cluster, and the Decentralized NAS.

### Deploy the Docker stacks

The playbook [playbooks/stacks-deploy.yml](playbooks/stacks-deploy.yml) deploys the Docker stacks.

### Restore stacks backups

The playbook [playbooks/stacks-restore-backups.yml](playbooks/stacks-restore-backup.yml) restores backups of stacks.

## Virtual environments

Several cases are available in the [inventories](./inventories) directory.

| |[vagrant-c1]|[vagrant-c2]|[vagrant-c3]|[rock64-c1]|
|---|---|---|---|---|
|nodes|1|2|3|1|
|https|no|no|no|no|
|keepalived|no|yes|yes|no|
|ceph|no|yes|yes|no|
|portainer|yes|yes|yes|yes|
|influxdata|yes|no|no|yes|
|nextcloud|yes|no|yes|yes|
|calibreweb|yes|no|yes|yes|
|backup|yes|yes|yes|yes|
|restore|no|yes|yes|no|
|dans|no|yes|yes|no|
|Armbian image|no|no|no|yes|

Examples starting with `vagrant-` can be fully deployed and tested using [vagrant] and [vagrant-libvirt].

[vagrant-c1]: inventories/vagrant-c1/README.md
[vagrant-c2]: inventories/vagrant-c2/README.md
[vagrant-c3]: inventories/vagrant-c3/README.md
[rock64-c1]: inventories/rock64-c1/README.md
[vagrant]: https://www.vagrantup.com/
[vagrant-libvirt]: https://github.com/vagrant-libvirt/vagrant-libvirt
