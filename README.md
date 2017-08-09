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

In particular, this tutorial can be executed on a cluster of Amazon EC2 instances - see appendix below on how to setup such a cluster.

# Setup



# Appendix: How to setup the tutorial on the Amazon Cloud

This tutorial can be executed on the Amazon Cloud by creating a cluster of EC2 instances that partecipate in a Docker Swarm. 

Start by launching an EC2 instance which will be the Swarm Manager, with the following characteristics:
* Use the latest Amazon Linux ECS optimized AMI (ami-57d9cd2e at the time of this writing)
* Choose a medium size server, for example t2.xlarge (4 CPUs, 16GB memory)
* Number of instances = 1
* Use expanded storage: 100GB for the root partition, and 100GB for the additional EBS disk
* Tag the instance with "Name=Swarm Manager Node" (to distinguish it from the others)
* When the EC2 instance starts up, automatically mount a pre-existing EFS volume to hold the shared directories (see the file SwamManagerNode.config as an example of "user data" to be specified in the "Instance Details" AWS launch wizard)

When this instance is ready, ssh into it and initialize the Docker Swarm, using the instance private IP as the Swarm Manager IP, for example:

export MANAGER_IP=172.20.9.14

Make note of the special token needed to join the Swarm as a worker node.

Then launch N additional EC2 instances to be Swarm Workers, using the same specificiations as above, except for the following:
* Number of instances = N
* Tag the instances with "Name=Swarm Worker Node"
* When each instance starts up, automatically mount the pre-existing EFS volume, and additionally join the existing Swarm as a worker (see the file SwarmWorkerNode, which needs to be modified for the specific Swarm Manager IP address, and the specific Swarm Worker token).

# Appendix: How to use RabbitMQ with a generic OODT-0.3 Docker architecture
