#!/usr/bin/env bash

set -xeo pipefail

vagrant up || true

SCENARIO="$1"

if [[ -z "$SCENARIO" ]]; then
  echo "usage: ./scripts/vm-test-scenario.sh SCENARIO"
  return 1
fi

vagrant ssh -- "
set -ex
cd /vagrant
virtualenv venv-vagrant
source venv-vagrant/bin/activate
molecule test -s $1
"
