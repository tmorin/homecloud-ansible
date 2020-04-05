# vagrant-c1

## Execute the test suite

```bash
scripts/test-vagrant-c1.sh
```

## Operations

### Create and start the VM

```bash
scripts/vagrant.sh c1 up
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
scripts/vagrant.sh c1 ssh c1-n1
```

### Destroy the VM

```bash
scripts/vagrant.sh c1 destroy --force
```
