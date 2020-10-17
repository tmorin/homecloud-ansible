# vagrant-c4

## Execute the test suite

```bash
scripts/test-vagrant-c4.sh
```

## Operations

### Create and start the VM

```bash
scripts/vagrant.sh c4 up
```

### Bootstrap the swarm

```bash
ansible-playbook -i inventories/vagrant-c4/inventory.yml swarm-bootstrap.yml
```

### Deploy the stacks

```bash
ansible-playbook -i inventories/vagrant-c4/inventory.yml stacks-deploy.yml
```

### Get an SSH access

```bash
scripts/vagrant.sh c4 ssh c4-n1
scripts/vagrant.sh c4 ssh c4-n2
scripts/vagrant.sh c4 ssh c4-n3
scripts/vagrant.sh c4 ssh c4-n4
```

### Destroy the VM

```bash
scripts/vagrant.sh c4 destroy --force
```
