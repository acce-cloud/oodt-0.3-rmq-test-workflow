#!/bin/sh
# Cleans up directories from previous workflows.
# Submits a new set of workflows using the RabbitMQ producer.

# identify the first worker container
wrkr_ids=`docker ps | grep oodt-wmgr | awk '{print $1}' | awk '{print $1}'`
wrkr_id=`echo $wrkr_ids | awk '{print $1;}'`
echo $wrkr_id

# clean up shared directories
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/*"
docker exec -it $wrkr_id ls -l /usr/local/oodt/pges/test-workflow/jobs

NJOBS=1
cd /usr/local/oodt/rabbitmq/
docker exec -it $wrkr_id sh -c "cd /usr/local/oodt/rabbitmq; python test_workflow_driver.py $NJOBS"
