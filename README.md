# oodt-0.3-rmq-test-workflow
Test workflow example using OODT-0.3 and RabbitMQ

# Summary
This tutorial provides an example on how to run and scale OODT services within a Docker Swarm environment
spanning multiple hosts. The tutorial sets up the following architecture (see attached figure):

* One File Manager (FM) container, deployed on the Swarm manager node
* One RabbitMQ (RMQ) server container, deployed on the Swarm manager node
* Two or more Workflow Manager (WM) containers, deployed on Swarm worker nodes
* For each Workflow Manager, a RMQ client co-located in the same container, which periodically pulls
  messages from the RMQ server and use them to submit workflows to the local WM
