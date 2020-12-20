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

The Ansible collection provides the following building blocks:

- a Docker Swarm with:
  - a layer4 load-balancer handled by `Keepalived`
  - a modern reverse proxy for UDP, TCP and HTTP handled by `Traefik`
- a distributed file system handled by `Ceph`
- a decentralized solution to synchronize files between local/remote nodes with `Syncthing`

The collection provides also ready-to-use stacks:

- `Influxdata` : a set of components to monitor the Docker Swarm.
- `Portainer` : a lightweight management UI to easily manage the Docker Swarm.
- `Nextcloud` : a platform providing the benefits of online collaboration without the compliance and security risks.
- `Calibreweb` :  a web app providing a clean interface for browsing, reading and downloading eBooks using an existing Calibre database.
- `Backup` : a system based on Duplicity and CRON which backups Docker volumes. 

Additionally, Armbian images can be created for each host of the inventory.

## Requirements

Each hosts must fulfilled the following constraints:

- Operating System: Ubuntu (18.04, 20.04) and Debian (Stretch, Buster)
- CPU Architecture: amd64 or arm64
- Memory: at least 2Go

If `ceph` is enabled:

- 1 available storage block device by OSD nodes ([more information there](https://docs.ceph.com/docs/master/cephadm/install/#deploy-osds))

## Dependencies

In order to build the custom Armbian images, additional dependencies are required:
```shell script
apt-get install jq qemu-system-arm qemu-user-static
```

The collection dependencies are bundled in [./collections.yml](collections.yml).
```shell script
ansible-galaxy collection install -r collections.yml
```

## Testing

Several cases are tested by continuous integration using [molecule], [vagrant] and the plugin [vagrant-libvirt].

### Tested layouts

The test suite targets the following operating systems:

- Ubuntu Bionic/Focal
- Debian Stretch/Buster

| |[c1]|[c1-ceph]|[c2]|[armbian]*|
|---|---|---|---|---|
|nodes|1|1|2|2|
|https|no|no|no|no|
|keepalived|yes|no|yes|no|
|ceph|no|yes|yes|no|
|portainer|yes|no|yes|no|
|influxdata|yes|no|no|no|
|nextcloud|yes|no|no|no|
|calibreweb|yes|no|no|no|
|backup|yes|no|yes|no|
|restore|no|no|yes|no|
|dans|yes|no|yes|no|
|hardening|no|yes|no|no|
|Armbian image|no|no|no|yes|

* the [armbian] scenario cannot be executed on Travis CI.

[c1]: molecule/c1
[c1-ceph]: molecule/c1-ceph
[c2]: molecule/c1
[armbian]: molecule/armbian
[molecule]: https://github.com/ansible-community/molecule
[vagrant]: https://www.vagrantup.com/
[vagrant-libvirt]: https://github.com/vagrant-libvirt/vagrant-libvirt

### Tested playbooks

The test suite plays several playbooks to configure the cluster nodes, to deploy the stacks and to perform restore operations.

They are located in the molecule directory: [molecule/resources/playbooks](molecule/resources/playbooks).

#### Hardening

The playbook [cluster-hardening.yml](molecule/resources/playbooks/cluster-hardening.yml) apply hardening recommendations on the operating system and SSH.
The activities are managed by the Ansible collection [devsec.hardening](https://galaxy.ansible.com/devsec/hardening).

#### Bootstrap the cluster

The playbook [cluster-bootstrap.yml](molecule/resources/playbooks/cluster-bootstrap.yml) bootstraps the cluster, i.e. the Docker Swarm instance, the Ceph cluster, and the Decentralized NAS.

#### Deploy the Docker stacks

The playbook [stacks-deploy.yml](molecule/resources/playbooks/stacks-deploy.yml) deploys the Docker stacks.

#### Restore stacks backups

The playbook [stacks-restore-backups.yml](molecule/resources/playbooks/stacks-restore-backup.yml) restores backups of stacks.
