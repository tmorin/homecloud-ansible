#!/usr/bin/env bash
rm -Rf playbooks/images/*
rm -Rf playbooks/vault/*
rm -Rf tmp/*
ansible-galaxy collection build --force
