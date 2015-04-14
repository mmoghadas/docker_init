docker_init
==================================
This tool allows you to quickly start a docker vm on your localhost
* Note: Currently tested on OSX


## Setup

```
# What you'll need:
-> docker client (brew install docker)
-> VirtualBox (https://www.virtualbox.org/wiki/Downloads)
-> Vagrant (http://www.vagrantup.com/downloads.html)

git clone git@github.com:mmoghadas/docker_init.git
cd docker_init
bundle

alias docker_init="bundle exec ./bin/docker_init"

docker_init -d ~/vagrant -n mydocker

# to start a cluster
docker_init -d ~/vagrant -n swarm -c 2
```


## Usage
```
#port: generate during setup(forwarded port from vm to localhost host)
#cluster_token_here: generated during setup
docker -H tcp://127.0.0.1:<port> run --rm swarm list token://<cluster_token_here>
docker -H tcp://127.0.0.1:<port> <docker_command_here>
```
