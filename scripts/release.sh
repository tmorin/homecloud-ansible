#!/usr/bin/env bash
set -x -e
rm -Rf playbooks/images/*
rm -Rf playbooks/vault/*
rm -Rf tmp/*
rm -Rf *.tgz
ansible-galaxy collection build --force
