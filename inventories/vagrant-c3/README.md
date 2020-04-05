# vagrant-c3

## Execute the test suite

```bash
scripts/test-vagrant-c3.sh
```

## Operations

### Create and start the VM

```bash
scripts/vagrant.sh c3 up
```

### Bootstrap the swarm

```bash
ansible-playbook -i inventories/vagrant-c1/inventory.yml swarm-bootstrap.yml
```

### Deploy the stacks

```bash
ansible-playbook -i inventories/vagrant-c1/inventory.yml stacks-deploy.yml
```

### Get an SSH access

```bash
scripts/vagrant.sh c3 ssh c3-n1
scripts/vagrant.sh c3 ssh c3-n2
scripts/vagrant.sh c3 ssh c3-n3
```

### Destroy the VM

```bash
scripts/vagrant.sh c3 destroy --force
```
