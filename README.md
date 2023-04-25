# homecloud-ansible

[![badge for Ansible Collection](https://img.shields.io/badge/Ansible%20Collection-tmorin/homecloud-blue?logo=ansible&logoColor=white)](https://galaxy.ansible.com/tmorin/homecloud)
[![badge for HTML paper](https://img.shields.io/badge/Paper-HTML-informational)](https://tmorin.github.io/homecloud-ansible)
[![badge for PDF paper](https://img.shields.io/badge/Paper-PDF-informational)](https://tmorin.github.io/homecloud-ansible/homecloud-paper.pdf)

[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/tmorin/homecloud-ansible/Continous%20Integration/master?label=GitHub%20Actions&logo=github+actions&logoColor=black)](https://github.com/tmorin/homecloud-ansible/actions?query=workflow%3A%22Continous+Integration%22+branch%3Amaster)

[comment]: <> ([![Travis &#40;.org&#41; branch]&#40;https://img.shields.io/travis/tmorin/homecloud-ansible/master?label=Travis%20CI&logo=travis+CI&logoColor=black&#41;]&#40;https://travis-ci.org/github/tmorin/homecloud-ansible&#41;)

> `homecloud` provides a ready-to-use set of resources to bootstrap a cloud at home mainly based on Kubernetes and Syncthing.

This is the **version 2** of the library.

The **version 1** of the library is available in the **v1.x branch**.

## Presentation

`homecloud` aims to provide a cloud like environment, especially an internal cloud, at home.
The underlying infrastructure is primarily based on low cost ARM boards, like Raspberry Pi, and powered by open source solutions like Kubernetes or Syncthing.

The main artifact is an Ansible collection designed to bootstrap a ready to use cloud like environment as well as a couple of end-users services.

An in-depth explanation is available in the [paper](./paper/README.adoc).

## Overview

The Ansible collection provides the following features:

- a `Kubernetes` cluster
- a modern reverse proxy for UDP, TCP and HTTP handled by `Traefik`
- a distributed block storage system handled by `Longhorn`
- the native Kubernetes dashboard
- a support of high availability handled by `Keepalived`
- a decentralized solution to synchronize files between local/remote nodes, `dnas`, powered with `Syncthing`, `NFS` and `Samba`

Additionally, Armbian images can be created for each host of the inventory.

Finally, once `homecloud` is bootstrapped, then end-user applications can be deployed on the `Kubernetes` cluster.
Some of them are available as `Kustomize` resources in another repository [tmorin/homecloud-kustomize](https://github.com/tmorin/homecloud-kustomize).

## Requirements

Each hosts must fulfill the following constraints:

- Operating System: Ubuntu (18.04, 20.04) and Debian (Stretch, Buster)
- CPU Architecture: amd64 or arm64
- Memory: at least 2Go

When `longhorn` is enabled, the data are stored a block device, i.e. `/dev/???`.
The collection handles the preparation of two kinds of block devices: 
the hardware component like a Sd-Card or a Loop Device based on a `.img` file.

When `dnas` is enabled, the data are stored a block device, i.e. `/dev/???`.
The collection handles the preparation of only block devices based on a hardware component like a Sd-Card, USB disk ...

## Dependencies

In order to build the custom Armbian images, additional dependencies are required:
```shell script
apt-get install jq qemu-system-arm qemu-user-static
```

## Local environment setup

Install dependencies for Vagrant and VirtualBox
```shell
sudo apt-get install -y vagrant virtualbox virtualbox-ext-pack
vagrant plugin install vagrant-vbguest
```

Create the Python virtual environment
```shell
virtualenv venv
source venv/bin/activate
```

Install the dependencies
```shell
pip install -r requirements.txt
```

The collection dependencies are bundled in [./molecule/resources/collections.yml](molecule/resources/collections.yml).
```shell
ansible-galaxy collection install -r molecule/resources/collections.yml
```

Lint the Ansible collection
```shell
./lint
```

## Testing

Several cases are tested using [molecule], [vagrant] and the plugin [vagrant-libvirt].

### Tested layouts

The test suite targets the following operating systems:

- Ubuntu
- Debian

|               | [k1] | [k1ha] | [k1lo] | [k2] | [k2ha] | [armbian] | [ubuntu_raspi] |
|---------------|------|--------|--------|------|--------|-----------|----------------|
| servers       | 1    | 1      | 1      | 1    | 2      | 0         | 0              |
| agents        | 0    | 0      | 0      | 1    | 0      | 0         | 0              |
| keepalived    | no   | yes    | no     | yes  | yes    | no        | no             |
| longhorn      | no   | yes    | yes    | yes  | yes    | no        | no             |
| traefik       | yes  | yes    | no     | yes  | yes    | no        | no             |
| dashboard     | yes  | no     | no     | no   | no     | no        | no             |
| dnas          | yes  | yes    | no     | no   | no     | no        | no             |
| hardening     | no   | no     | no     | no   | no     | no        | no             |
| Armbian image | no   | no     | no     | no   | no     | yes       | no             |
| Ubuntu image  | no   | no     | no     | no   | no     | no        | yes            |

Test the scenario `k1`
```shell
source venv/bin/activate
molecule test -s k1
```

Configure local (Ansible agent) kubectl for `k1`
```shell
export KUBECONFIG=$HOME/.kube/k1
kubectl get all --all-namespaces
```

Configure local (Ansible agent) kubectl for `k1ha`
```shell
export KUBECONFIG=$HOME/.kube/k1ha
kubectl get all --all-namespaces
```

Configure local (Ansible agent) kubectl for `k2`
```shell
export KUBECONFIG=$HOME/.kube/k2
kubectl get all --all-namespaces
```

Configure local (Ansible agent) kubectl for `k2ha`
```shell
export KUBECONFIG=$HOME/.kube/k2ha
kubectl get all --all-namespaces
```

[k1]: molecule/k1
[k1ha]: molecule/k1ha
[k1lo]: molecule/k1lo
[k2]: molecule/k2
[k2ha]: molecule/k2ha
[armbian]: molecule/armbian
[ubuntu_raspi]: molecule/ubuntu_raspi
[molecule]: https://github.com/ansible-community/molecule
[vagrant]: https://www.vagrantup.com/
[vagrant-libvirt]: https://github.com/vagrant-libvirt/vagrant-libvirt

### Tested playbooks

The test suite plays several playbooks to configure the cluster nodes, to deploy the stacks and to perform restore operations.

They are located in the molecule directory: [molecule/resources/playbooks](molecule/resources/playbooks).

#### Hardening

Presently, the repository doesn't provide playbooks for OS hardening.
However, an existing initiative may help you to build your own: [devsec.hardening](https://galaxy.ansible.com/devsec/hardening).

#### Bootstrap the cluster

The playbook [cluster-bootstrap.yml](molecule/resources/playbooks/cluster-bootstrap.yml) bootstraps the cluster, i.e. the Kubernetes cluster and the Decentralized NAS.

#### Deploy the Kubernetes deployment manifests

The playbook [k3s-deploy.yml](molecule/resources/playbooks/k3s-deploy.yml) deploys the Kubernetes deployment manifests.
