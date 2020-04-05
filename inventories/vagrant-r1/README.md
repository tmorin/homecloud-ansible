# vagrant-r1

## Execute the test suite

```bash
scripts/test-vagrant-r1.sh
```

## Operations

### Create and start the VM

```bash
scripts/vagrant.sh r1 up
```

### Bootstrap the swarm

```bash
ansible-playbook -i inventories/vagrant-r1/inventory.yml swarm-bootstrap.yml
```

### Deploy the stacks

```bash
ansible-playbook -i inventories/vagrant-c1/inventory.yml stacks-deploy.yml
```

### Get an SSH access

```bash
scripts/vagrant.sh r1 ssh r1-n1
```

### Destroy the VM

```bash
scripts/vagrant.sh r1 destroy --force
```
