# homecloud-ansible

[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/tmorin/homecloud-ansible/Continous%20Integration/master?label=GitHub%20Actions&logo=github+actions&logoColor=black)](https://github.com/tmorin/homecloud-ansible/actions?query=workflow%3A%22Continous+Integration%22+branch%3Amaster)
[![Travis (.org) branch](https://img.shields.io/travis/tmorin/homecloud-ansible/master?label=Travis%20CI&logo=travis+CI&logoColor=black)](https://travis-ci.org/github/tmorin/homecloud-ansible)

> `homecloud` provides a ready-to-use set of resources to bootstrap a cloud at home mainly based on Kubernetes and Syncthing.

This is the **version 2** of the library.

The **version 1** of the library is available in the **v1.x branch**.

## Presentation

`homecloud` aims to provide a cloud like environment, especially an internal cloud, at home.
The underlying infrastructure is primarily based on low cost ARM boards, like Raspberry Pi, and powered by open source solutions like Kubernetes or Syncthing.

The main artifact is an Ansible collection designed to bootstrap a ready to use cloud like environment as well as a couple of end-users services.

An in-depth explanation is available in the [paper](./paper/README.adoc).

## Overview

The Ansible collection provides the following building blocks:

- a `Kubernetes` cluster
- a support of high availability handled by `Keepalived`
- a modern reverse proxy for UDP, TCP and HTTP handled by `Traefik`
- a distributed block storage system handled by `Longhorn`
- a decentralized solution to synchronize files between local/remote nodes, `dnas`, powered with `Syncthing`, `NFS` and `Samba`

The collection provides also ready-to-use services:

- `Kubernetes Dashboard` : the built-in Kubernetes Dashboard.
- `Nextcloud` : a platform providing the benefits of online collaboration without the compliance and security risks.
- `Calibreweb` :  a web app providing a clean interface for browsing, reading and downloading eBooks using an existing Calibre database.

Additionally, Armbian images can be created for each host of the inventory.

## Requirements

Each hosts must fulfilled the following constraints:

- Operating System: Ubuntu (18.04, 20.04) and Debian (Stretch, Buster)
- CPU Architecture: amd64 or arm64
- Memory: at least 2Go

If `longhorn` is enabled: 1 available storage block device (i.e. an sd-card, an usb disk ...) for each node storing data

If `dnas` is enabled: 1 available storage block device (i.e. an sd-card, an usb disk ...) for each node storing data

## Local environment setup

Create the Python virtual environment
```shell
virtualenv venv
source venv/bin/activate
```

Install the dependencies
```shell
pip install -r requirements.txt
```

Lint the Ansible collection
```shell
./lint
```

Configure local (Ansible agent) kubectl
```shell
export KUBECONFIG=$HOME/.kube/homecloud
kubectl get all --all-namespaces
```

## Dependencies

In order to build the custom Armbian images, additional dependencies are required:
```shell script
apt-get install jq qemu-system-arm qemu-user-static
```

The collection dependencies are bundled in [./molecule/resources/collections.yml](molecule/resources/collections.yml).
```shell
ansible-galaxy collection install -r molecule/resources/collections.yml
```

## Testing

Several cases are tested by continuous integration using [molecule], [vagrant] and the plugin [vagrant-libvirt].

### Tested layouts

The test suite targets the following operating systems:

- Ubuntu Bionic/Focal
- Debian Stretch/Buster

| |[k1]|[k1ha]|[k2]|[k2ha]|[armbian]*|
|---|---|---|---|---|---|
|servers|1|1|1|2|0|
|agents|0|0|1|2|0|
|keepalived|no|yes|yes|yes|no|
|longhorn|no|yes|yes|yes|no|
|traefik|yes|yes|yes|yes|no|
|dashboard|yes|no|no|no|no|
|calibre-web|yes|no|no|no|no|
|nextcloud|yes|no|no|no|no|
|dnas|yes|yes|no|no|no|
|hardening|no|no|no|no|no|
|Armbian image|no|no|no|no|yes|

* the [armbian] scenario cannot be executed on Travis CI.


Configure local (Ansible agent) kubectl for k1
```shell
export KUBECONFIG=$HOME/.kube/k1
kubectl get all --all-namespaces
```

Configure local (Ansible agent) kubectl for k1ha
```shell
export KUBECONFIG=$HOME/.kube/k1ha
kubectl get all --all-namespaces
```

Configure local (Ansible agent) kubectl for k2
```shell
export KUBECONFIG=$HOME/.kube/k2
kubectl get all --all-namespaces
```

Configure local (Ansible agent) kubectl for k2ha
```shell
export KUBECONFIG=$HOME/.kube/k2ha
kubectl get all --all-namespaces
```

[k1]: molecule/k1
[k1ha]: molecule/k1ha
[k2]: molecule/k2
[k2ha]: molecule/k2ha
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

The playbook [cluster-bootstrap.yml](molecule/resources/playbooks/cluster-bootstrap.yml) bootstraps the cluster, i.e. the Kubernetes cluster and the Decentralized NAS.

#### Deploy the Kubernetes deployment manifests

The playbook [k3s-deploy.yml](molecule/resources/playbooks/k3s-deploy.yml) deploys the Kubernetes deployment manifests.
