#!/usr/bin/env bash
source set_vars.sh

"${SC_MACHINE_PATH}/scripts/install_deps_ubuntu.sh" $@

packagelist=(
	python3-pip
	python3-setuptools
	libssl-dev
	file
)
sudo apt-get install -y --no-install-recommends "${packagelist[@]}"
