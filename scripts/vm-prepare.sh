#!/usr/bin/env bash

set -xeo pipefail

sudo apt-get install -y vagrant virtualbox virtualbox-ext-pack

vagrant plugin install vagrant-vbguest

vagrant up || true

vagrant ssh -- "
set -ex
cd /vagrant
virtualenv venv-vagrant
source venv-vagrant/bin/activate
pip install -r requirements.txt
"
