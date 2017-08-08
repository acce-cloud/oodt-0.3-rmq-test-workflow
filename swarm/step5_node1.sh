#!/bin/sh
# Cleans up directories from previous workflows.
# Submits a new set of workflows using the RabbitMQ producer.

# identify the first worker container
cids=`docker ps | grep oodt-rabbitmq | awk '{print $1}' | awk '{print $1}'`
cid=`echo $cids | awk '{print $1;}'`
echo $wrkr_id

NJOBS=10
docker exec -it $cid sh -c "cd /usr/local/oodt/rabbitmq; python test_workflow_driver.py $NJOBS"
