#!/usr/bin/env bash

set -e

# check if environmental variables are set
: ${VAGRANTHOME?"Need to set VAGRANTHOME"}
: ${VAGRANTNAME?"Need to set VAGRANTNAME"}

# set variables locally
export VAGRANT_DIR=${VAGRANTHOME}/${VAGRANTNAME}

# initialize a new vagrant file
mkdir -p $VAGRANT_DIR
cd $VAGRANT_DIR

cat <<EOF > Vagrantfile
Vagrant.configure(2) do |config|
  config.vm.box = "centos7"
  config.vm.box_url = "https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box"
  config.vm.network "forwarded_port", guest: 2375, host: 2375
  config.vm.network "forwarded_port", guest: 2376, host: 2376

  config.vm.provider "virtualbox" do |v|
    v.name = "$VAGRANTNAME"
  end

  config.vm.provision "shell", path: "https://raw.githubusercontent.com/mmoghadas/docker_init/master/provision.sh"
end
EOF

vagrant up