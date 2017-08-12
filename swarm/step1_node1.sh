#!/bin/sh
# Initializes the swarm

#export MANAGER_IP=172.20.5.254
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
echo $token_worker

docker network create -d overlay swarm-network
docker run -it -d -p 8080:8080 -e HOST=$MANAGER_IP -e PORT=8080 -v /var/run/docker.sock:/var/run/docker.sock --name visualizer dockersamples/visualizer:stable
