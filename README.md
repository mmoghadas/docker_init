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


# to enable tls
# you must add an alias to your localhost for this to work
# 127.0.0.1       localhost docker.example.com
docker_init -d ~/vagrant -n mydocker --tls -h docker.example.com
```


## Usage
```
export DOCKER_HOST=tcp://localhost:<port_number>
docker ps


# for tls you will also need:
export DOCKER_HOST=tcp://docker.example.com:<port_number> DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=~/.docker_init/<vagrant_name>
```
