# oodt-0.3-rmq-test-workflow
Test workflow example using OODT-0.3 and RabbitMQ.

# Summary
This tutorial provides an example on how to run and scale OODT services within a Docker Swarm environment
spanning multiple hosts. The tutorial sets up the following architecture (see attached figure):

* One File Manager (FM) container, deployed on the Swarm manager node
* One RabbitMQ (RMQ) server container, deployed on the Swarm manager node
* Two or more Workflow Manager (WM) containers, deployed on Swarm worker nodes
* For each Workflow Manager, a RMQ client co-located in the same container, which periodically pulls
  messages from the RMQ server and use them to submit workflows to the local WM
  
This tutorial is based on Docker images built from OODT 0.3.
  
# Pre-Requisites
* A cluster of N hosts with Docker installed
* A shared disk cross-mounted across all hosts, used to store the following directories:
  * OODT FM and WM configuration, which must be accessible by all containers
  * The jobs execution directory, where all containers write the output product that need to be harvested
  * The data archive directory, where the output products are moved upon crawling
* Git installed on one host
