#!/bin/sh
# Instantiates services on the swarm.
# Note that all services must have access to shared directories on the host

# start file manager on swarm manager node
docker service create --replicas 1 --name oodt-filemgr -p 9000:9000 --network swarm-network \
                      --constraint 'node.role == manager' \
                      --mount type=bind,src=$OODT_CONFIG/workflows/test-workflow/policy,dst=/usr/local/oodt/workflows/policy \
                      --mount type=bind,src=$OODT_ARCHIVE,dst=/usr/local/oodt/archive \
                      --mount type=bind,src=$OODT_JOBS,dst=/usr/local/oodt/pges/test-workflow/jobs \
                      oodthub/oodt-filemgr:0.3

# start RabbitMQ server on swarm manager node
docker service create --replicas 1 --name oodt-rabbitmq -p 5672:5672 -p 15672:15672 --network swarm-network \
                      --constraint 'node.role == manager' \
                      --mount type=bind,src=$OODT_CONFIG/rabbitmq_clients/test_workflow_driver.py,dst=/usr/local/oodt/rabbitmq/test_workflow_driver.py \
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@localhost/%2f' \
                      --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@localhost:15672' \
                      oodthub/oodt-rabbitmq                    

# start workflow 
docker service create --replicas 1 --name oodt-wmgr --network swarm-network \
                      --constraint 'node.role != manager' \
                      --mount type=bind,src=$OODT_CONFIG/workflows/test-workflow/policy,dst=/usr/local/oodt/workflows/policy \
                      --mount type=bind,src=$OODT_CONFIG/workflows/test-workflow/pge-configs,dst=/usr/local/oodt/workflows/test-workflow/pge-configs \
                      --mount type=bind,src=$OODT_CONFIG/pges/test-workflow,dst=/usr/local/oodt/pges/test-workflow \
                      --mount type=bind,src=$OODT_CONFIG/conf/supervisord.conf,dst=/etc/supervisor/supervisord.conf \
                      --mount type=bind,src=$OODT_JOBS,dst=/usr/local/oodt/pges/test-workflow/jobs \
                      --mount type=bind,src=$OODT_ARCHIVE,dst=/usr/local/oodt/archive \
                      --env 'FILEMGR_URL=http://oodt-filemgr:9000/' \
                      --env 'WORKFLOW_URL=http://localhost:9001' \
                      --env 'RABBITMQ_USER_URL=amqp://oodt-user:changeit@oodt-rabbitmq/%2f' \
                      --env 'RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@oodt-rabbitmq:15672' \
                      --env 'WORKFLOW_QUEUE=test-workflow' \
                      --env 'MAX_WORKFLOWS=1' \
                      oodthub/oodt-wmgr:0.3
docker service scale oodt-wmgr=2

docker service ls
