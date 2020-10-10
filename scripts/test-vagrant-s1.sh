#!/bin/bash

export CLUSTER="s1"
export homecloud_IP="192.168.10.11"

. $(pwd)/scripts/include.sh

bootstrapVagrant
playbook nas-install.yml
