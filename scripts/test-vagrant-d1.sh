#!/bin/bash

export CLUSTER="d1"
export homecloud_IP="192.168.10.11"

. $(pwd)/scripts/include.sh

bootstrapVagrant
checkVM 1
playbook cluster-hardening.yml
playbook cluster-bootstrap.yml
