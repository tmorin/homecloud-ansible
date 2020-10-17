# vagrant-d1

## Execute the test suite

```bash
scripts/test-vagrant-d1.sh
```

## Operations

### Create and start the VM

```bash
scripts/vagrant.sh d1 up
```

### Bootstrap the swarm

```bash
ansible-playbook -i inventories/vagrant-d1/inventory.yml swarm-bootstrap.yml
```

### Deploy the stacks

```bash
ansible-playbook -i inventories/vagrant-d1/inventory.yml stacks-deploy.yml
```

### Get an SSH access

```bash
scripts/vagrant.sh d1 ssh d1-n1
```

### Destroy the VM

```bash
scripts/vagrant.sh d1 destroy --force
```
