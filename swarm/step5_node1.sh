#!/bin/sh
# Removes all services from the swarm

docker service rm oodt-filemgr oodt-rabbitmq oodt-wmgr
docker service ls
