docker_init
==================================
This tool allows you to quickly start a docker vm on your localhost
* Note: Currently tested on OSX


## Usage

```bash
git clone git@github.com:mmoghadas/docker_init.git
cd docker_init

# VAGRANTHOME is where you typically save your vagrant files
export VAGRANTHOME=~/vagrant
# VAGRANTHOME is the name of your new docker vm

export VAGRANTNAME=docker
sh bootstrap.sh
```bash