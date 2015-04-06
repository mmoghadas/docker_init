docker_init
==================================
This tool allows you to quickly start a docker vm on your localhost
* Note: Currently tested on OSX


## Setup

```
git clone git@github.com:mmoghadas/docker_init.git
cd docker_init
bundle

alias docker_init="bundle exec ./bin/docker_init"

docker_init -d ~/vagrant -n mydocker
```


## Usage
```
export DOCKER_HOST=tcp://localhost:<port_number>
docker ps
```
