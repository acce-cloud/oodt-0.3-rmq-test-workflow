#!/bin/sh
# Submits a new set of workflows using the RabbitMQ producer.
# Must be execute on the host running the RabbitMQ container.

# identify the rabbitmq container
cids=`docker ps | grep oodt-rabbitmq | awk '{print $1}' | awk '{print $1}'`
cid=`echo $cids | awk '{print $1;}'`
echo $cid

NJOBS=10
docker exec -i $cid sh -c "cd /usr/local/oodt/rabbitmq; python test_workflow_driver.py $NJOBS"
