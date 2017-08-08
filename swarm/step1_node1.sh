#!/bin/sh
# Initializes the swarm

export MANAGER_IP=172.20.14.73
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
echo $token_worker

docker network create -d overlay swarm-network
