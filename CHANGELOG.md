# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [2.6.1](https://github.com/tmorin/homecloud-ansible/compare/v2.6.0...v2.6.1) (2021-10-26)


### Bug Fixes

* **k3s_longhorn:** dd parameter must be configurable to handle low cost dev board ([246a26f](https://github.com/tmorin/homecloud-ansible/commit/246a26fc3e3866ae12b8df537c9138a251004759))

## [2.6.0](https://github.com/tmorin/homecloud-ansible/compare/v2.5.1...v2.6.0) (2021-10-25)


### Features

* **image_aosc:** add support to customize ASOC images ([353e3d6](https://github.com/tmorin/homecloud-ansible/commit/353e3d6738b31d70f461b1075730b473e88d3069))
* **image_armbian:** add an option to override the MAC address ([a4b9973](https://github.com/tmorin/homecloud-ansible/commit/a4b99736bae4e6321f0bcd31a962132951f8d9d5))

### [2.5.1](https://github.com/tmorin/homecloud-ansible/compare/v2.5.0...v2.5.1) (2021-09-20)


### Bug Fixes

* **k3s_longhorn:** the role should not fail when the image is already mounted ([fd4997d](https://github.com/tmorin/homecloud-ansible/commit/fd4997d1a7044ff3f6ba3b3179236f8ddeda47a0))

## [2.5.0](https://github.com/tmorin/homecloud-ansible/compare/v2.4.0...v2.5.0) (2021-09-20)


### Features

* **service_k3s:** nodes can be tainted ([9fdd2f7](https://github.com/tmorin/homecloud-ansible/commit/9fdd2f73381343ee5b8b8f8f15e66db7864bcbb7))
* **service_k3s:** the k3s version can be overridden ([b458a0e](https://github.com/tmorin/homecloud-ansible/commit/b458a0ec55d0e1534c07d834a1dbe92886e64950))
* **service_k3s:** upgrade Kustomize to v4.3.0 ([8bcb6bd](https://github.com/tmorin/homecloud-ansible/commit/8bcb6bd3c44059edfe37f02cb93e94e1ae4bd3ce))


### Bug Fixes

* **image_armbian:** force `sync` before and after mount/losetup operations ([1354053](https://github.com/tmorin/homecloud-ansible/commit/1354053576ded7c60e9c797e77440c9e0e06ef38))
* **image_ubuntu_raspi:** force `sync` before and after mount/losetup operations ([8cc97a7](https://github.com/tmorin/homecloud-ansible/commit/8cc97a78ba8a4062e993a93d91001b3bcf14a073))
* **k3s_longhorn:** the role cannot be run twice when the image flavor is selected ([58afd49](https://github.com/tmorin/homecloud-ansible/commit/58afd492a06f62bf3fd580935cfbf6a71a8b0643))

## [2.4.0](https://github.com/tmorin/homecloud-ansible/compare/v2.3.0...v2.4.0) (2021-09-14)


### Features

* add support for Debian 11 (Bullseye) ([327208c](https://github.com/tmorin/homecloud-ansible/commit/327208c6643e93a2d2cfd209fd16fc84ed667d04))
* **image_ubuntu_raspi:** add support to build Ubuntu images for Raspberry Pi ([3003c4a](https://github.com/tmorin/homecloud-ansible/commit/3003c4a74a0a50b38a8dfdfca3211399df2c7a4f))
* **k3s_csi_driver_smb:** add an option to set a specific version ([3fee9b6](https://github.com/tmorin/homecloud-ansible/commit/3fee9b6cda1141eeec83db46d7c58b787555c406))


### Bug Fixes

* **k3s_longhorn:** the Longhorn disk can also be a an image available with a Loop Device ([8c6b867](https://github.com/tmorin/homecloud-ansible/commit/8c6b867f3b319594b5d5c2fd6437bcba382bed9a))
* **paper:** simple typo fixes ([2537aaf](https://github.com/tmorin/homecloud-ansible/commit/2537aaff8d0ee6d460393dd761f1cd75e95569f7))

## [2.3.0](https://github.com/tmorin/homecloud-ansible/compare/v2.2.1...v2.3.0) (2021-04-01)


### Features

* **k3s_dnas:** the NFS share should be the root path ([fdedc84](https://github.com/tmorin/homecloud-ansible/commit/fdedc84a8ec97ca52024003b46ec7754bbc0c175))


### Bug Fixes

* **k3s_longhorn:** increase the timeout for the tasks "Wait for Longhorn" ([7e9ac01](https://github.com/tmorin/homecloud-ansible/commit/7e9ac01f9df32eda4726075b8b026a089063de0d))

### [2.2.1](https://github.com/tmorin/homecloud-ansible/compare/v2.2.0...v2.2.1) (2021-03-31)


### Bug Fixes

* **paper:** publication is broken ([b99e15a](https://github.com/tmorin/homecloud-ansible/commit/b99e15a51acf38eaad9de4780f60e1c0202b0f0c))

## [2.2.0](https://github.com/tmorin/homecloud-ansible/compare/v2.1.0...v2.2.0) (2021-03-31)


### Features

* upgrade to Ansible 3.1 ([e250f7e](https://github.com/tmorin/homecloud-ansible/commit/e250f7ea1fe7577a1afd1d4c7e1da9a5d9729263))


### Bug Fixes

* **k3s_dnas:** improve `dnas-share` Deployment with `requiredDuringSchedulingIgnoredDuringExecution` ([78cfe18](https://github.com/tmorin/homecloud-ansible/commit/78cfe1847e5dff459ac89e582bef05ea47f60ed9))
* **paper:** add descrption of k3s_dnas ([4082d7d](https://github.com/tmorin/homecloud-ansible/commit/4082d7d991009de997c88793d96f10fdee2f1f3d))
* **service_k3s:** configuration of the ansible agent was badly done ([e581234](https://github.com/tmorin/homecloud-ansible/commit/e58123490e92669c8fdc763a01e80a306145309a))
* **service_k3s:** workers were badly annotated ([04051fe](https://github.com/tmorin/homecloud-ansible/commit/04051fe3b1d8194d96d54f1313c5e9d2b05b5255))

## [2.1.0](https://github.com/tmorin/homecloud-ansible/compare/v2.0.0...v2.1.0) (2021-03-29)


### Features

* **dnas:** refactor dnas service ([f72e60f](https://github.com/tmorin/homecloud-ansible/commit/f72e60fa90c12baa51afa9d6faad93018cab8934))
* **paper:** introduce the container engine and orchestrator technologies ([57276e3](https://github.com/tmorin/homecloud-ansible/commit/57276e31cb5fb6d903d2a0b984c45cc6005a8197))

## [2.0.0](https://github.com/tmorin/homecloud-ansible/compare/v1.6.0...v2.0.0) (2021-03-17)


### Features

* **k3s:** add helm and kubectl configuration ([296214b](https://github.com/tmorin/homecloud-ansible/commit/296214b820080e99337503d8724cad8b7767ac78))
* **k3s:** add the k3s_service ([95153cb](https://github.com/tmorin/homecloud-ansible/commit/95153cb27161d1ef0b24aaa0060d529756b14b21))
* **k3s_calibreweb:** integrates the calibre-web ([c0a5382](https://github.com/tmorin/homecloud-ansible/commit/c0a53823a8cb5830010c5acada7597337d4a8e7d))
* **k3s_csi-driver-smb:** integrates the driver ([a1ffbbb](https://github.com/tmorin/homecloud-ansible/commit/a1ffbbba32f3729de4ea463aaed7571a93ca3096))
* **k3s_dashboard:** integrates the Kubernetes Dashboard ([bcb3873](https://github.com/tmorin/homecloud-ansible/commit/bcb387393c517d1f54e64fa69b23decca93b2655))
* **k3s_longhorn:** add integration tests ([f166521](https://github.com/tmorin/homecloud-ansible/commit/f16652109560b2fc5d6443274b1b7c7e53157272))
* **k3s_longhorn:** integrates the Longhorn distributed block storage ([3fa494d](https://github.com/tmorin/homecloud-ansible/commit/3fa494df2c20426c4d3d121e7eae503f093eb58a))
* **k3s_nextcloud:** integrates nextcloud ([43eac8d](https://github.com/tmorin/homecloud-ansible/commit/43eac8d8437cb1c0226e0ed2f6873d50224e785b))
* **k3s_traefik:** integrates the Traefik modern proxy ([1214457](https://github.com/tmorin/homecloud-ansible/commit/1214457b82df97e82c5029bafea3728f6c319c71))
* **paper:** review content ([545761e](https://github.com/tmorin/homecloud-ansible/commit/545761e8ebe40ade5d14e596b9bc4890cbdfff65))
* **service_dnas:** integrates the Dnas layout ([7aa35f7](https://github.com/tmorin/homecloud-ansible/commit/7aa35f7955ee92b617e2c274ea78dd64985f21d5))
* **service_k3s:** add support for Traefik customizations ([af64715](https://github.com/tmorin/homecloud-ansible/commit/af647157a22bef6726efd40ff6e929d899b4d442))
* **service_k3s:** add the kustomize installation ([67da8cc](https://github.com/tmorin/homecloud-ansible/commit/67da8cc52f3c4776ab2333fbafe73288d0c993a2))
* **service_k3s:** export the k8s context to ansible agent ([c35102f](https://github.com/tmorin/homecloud-ansible/commit/c35102fcbcafb1126feb196ea7dd6f6727d73fe7))
* **service_keepalived:** integrates Keepalived to provide high-availability ([eb84302](https://github.com/tmorin/homecloud-ansible/commit/eb84302f2d551de1b88e1684a722b32ee79fa2ef))


### Bug Fixes

* **collection:** the Ceph plugin is not installed on all expected hosts ([08a22cb](https://github.com/tmorin/homecloud-ansible/commit/08a22cb1f00492b1d961da54fc5eecbdba211d0b))
* **paper:** fix typo ([7cc9ac1](https://github.com/tmorin/homecloud-ansible/commit/7cc9ac103fd7cbdc9721924ba6d6ff754a696555))
* **stack_backup:** add missing platforms in metadata ([ac06c2d](https://github.com/tmorin/homecloud-ansible/commit/ac06c2d8b702ff6bdd04779a4cc1f048ea16ff9c))
* **stack_calibreweb:** add missing platforms in metadata ([364d832](https://github.com/tmorin/homecloud-ansible/commit/364d8321b60c5e21e646accc7a439b6cd8546f6d))
* **stack_influxdata:** add missing platforms in metadata ([78c2407](https://github.com/tmorin/homecloud-ansible/commit/78c2407aa95c36d6a838085168923a5b5f20fda4))
* **stack_nextcloud:** add missing platforms in metadata ([2590875](https://github.com/tmorin/homecloud-ansible/commit/259087544221e7e00432cc82ef47a596917d6f56))
* **stack_portainer:** add missing platforms in metadata ([ee9b873](https://github.com/tmorin/homecloud-ansible/commit/ee9b87309781218d2c515cad0954311ee84233a8))
* **stack_traefik:** add missing platforms in metadata ([04fb05b](https://github.com/tmorin/homecloud-ansible/commit/04fb05b29b8856771563f648bbf609a35117692b))

## [1.6.0](https://github.com/tmorin/homecloud-ansible/compare/v1.5.0...v1.6.0) (2021-02-15)


### Features

* add support for Ubuntu 18.04/20.04 and Debian 9/10 ([46da4f0](https://github.com/tmorin/homecloud-ansible/commit/46da4f096ef141d7732275e66aa7328ed9a9bbb7))


### Bug Fixes

* **collection:** add missing dependency ([db9eff8](https://github.com/tmorin/homecloud-ansible/commit/db9eff87fe2e69a7d8a0af7446e6c770fc2a7399))
* lint the collection source ([074c45b](https://github.com/tmorin/homecloud-ansible/commit/074c45baea2386775887fe3a6583f77bfbf1918f))

## [1.5.0](https://github.com/tmorin/homecloud-ansible/compare/v1.4.1...v1.5.0) (2020-12-15)


### Features

* rename some variables to improve readability ([3bd861c](https://github.com/tmorin/homecloud-ansible/commit/3bd861c0e9adf5dd3972e35eb473dfbecaa20ab8))
* switch to the Ansible collection `devsec.hardening` ([b3e7829](https://github.com/tmorin/homecloud-ansible/commit/b3e782926b920053e2641bbe7edbd0a32bee4455))


### Bug Fixes

* improve the README.md ([d9a57a8](https://github.com/tmorin/homecloud-ansible/commit/d9a57a8a07fa809b3d511e536cfa133ce3bdb95c))
