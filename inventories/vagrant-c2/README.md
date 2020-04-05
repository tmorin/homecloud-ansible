# vagrant-c2

## Execute the test suite

```bash
scripts/test-vagrant-c2.sh
```

## Operations

### Create and start the VM

```bash
scripts/vagrant.sh c2 up
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
scripts/vagrant.sh c2 ssh c2-n1
scripts/vagrant.sh c2 ssh c2-n2
```

### Destroy the VM

```bash
scripts/vagrant.sh c2 destroy --force
```
