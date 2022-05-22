#!/usr/bin/env bash

set -xeo pipefail

npm run release:alpha

rm -f collection/tmorin-homecloud-*.tar.gz

cd collection \
  && ansible-galaxy collection build --force \
  && ansible-galaxy collection publish --token "${ANSIBLE_GALAXY_API_KEY}" tmorin-homecloud-*.tar.gz
