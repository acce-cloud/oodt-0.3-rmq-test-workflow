#!/bin/sh
# Removes the swarm.

docker node rm $WORKER1_IP
docker node rm $WORKER2_IP
docker swarm leave --force
