#!/usr/bin/env bash
set -x -e
rm -Rf playbooks/images/*
rm -Rf playbooks/vault/*
rm -Rf tmp/*
rm -Rf *.gz
ansible-galaxy collection build --force
