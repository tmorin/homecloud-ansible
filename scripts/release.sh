#!/usr/bin/env bash
rm -Rf images/*
rm -Rf playbooks/vault/*
rm -Rf tmp/*
ansible-galaxy collection build --force
