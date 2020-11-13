#!/usr/bin/env bash
project_dir="$(dirname "$0")/.."
id="${1}"
shift
cd "${project_dir}/inventories/vagrant-${id}"
vagrant "$@"
