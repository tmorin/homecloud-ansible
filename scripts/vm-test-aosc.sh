#!/usr/bin/env bash

set -xeo pipefail

vagrant up || true

vagrant ssh -- "
set -ex
cd /vagrant
virtualenv venv-vagrant
source venv-vagrant/bin/activate
molecule test -s aosc
"
