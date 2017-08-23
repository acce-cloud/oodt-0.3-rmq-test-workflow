# oodt-0.3-rmq-test-workflow
Test workflow example using OODT-0.3 and RabbitMQ, and optionally a Workflow Manager Proxy.

# Summary

This tutorial provides an example on how to run and scale OODT services within a Docker Swarm environment
spanning multiple hosts. The tutorial sets up the following architecture (see attached figure):

* One File Manager (FM) container, deployed on the Swarm manager node
* One RabbitMQ (RMQ) server container, deployed on the Swarm manager node
* Two or more Workflow Manager (WM) containers, deployed on Swarm worker nodes
* For each WM container, a RMQ client co-located in the same container, which periodically pulls
  messages from the RMQ server and use them to submit workflows to the local WM
* Optionally, for each WM container, an Workflow Manager Proxy (WMP) which intercepts requests to the WM and converts them to messages sent to the RMQ server.
  
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

Choose one of the hosts to be the Swarm Manager, and connect to it via ssh. Then:

* Create a directory to be used as shared disk by all containers. For example:

  mkdir -p /shared-data/test

* Check out this Git repository which contains the necessary configuration for the OODT services:

  mkdir -p /shared-data/test/src

  cd /shared-data/test/src

  git clone https://github.com/oodt-cloud/oodt-0.3-rmq-test-workflow.git

  cd oodt-0.3-rmq-test-workflow

  export OODT_CONFIG=\`pwd\`

* Define env variables referencing the other shared directories, and create them:
  
  export OODT_ARCHIVE=/shared_data/test/archive
  
  mkdir -p $OODT_ARCHIVE
  
  export OODT_JOBS=/shared_data/test/pges/test-workflow/jobs
  
  mkdir -p $OODT_JOBS

* Define an env variable for the IP address of the current (Swarm manager) host, for example:

  export MANAGER_IP=172.20.5.254

# Execution

Follow the tutorial by executing the step-by-step scripts contained in the directory $OODT_CONFIG/swarm. All scripts must be executed on the Swarm manager node, unless otherwise stated.

* Create the Swarm:

  ./step1_node1.sh

  The above command will create a Docker Swarm, and set up the current host as Swarm manager. Capture the output of the previous command   and execute it on all the other hosts so they can join the Swarm as workers (step2_nodeI.sh), for example:

  docker swarm join \  
    --token SWMTKN-1-2q67pe5u9y0sqggtgy6ksn6zxnle1ol82e5ql765ltgjfu3iii-exk4ejrah7h1y3s8kcmtcki88 172.20.5.254:2377
    
  Verify that all nodes have joined the Swarm:
  
  docker node ls

* a) Start the OODT services, deploying the Docker containers onto the appropriate swarm nodes:

  ./step3_node1.sh
  
  Note: the parameter MAX_WORKFLOWS inside the script defines the maximum number of workflows that can be run concurrently within each WM.
  
  Wait untill all services are in a running state:
  
  docker service ls
  
  Optionally, increase the number of WM containers:
  
  docker service scale oodt-wmgr=4
  
* b) Alternatively, start the OODT services in the "proxy" configuration:

  ./step3-proxy_node1.sh
  
  In this configuration, on each worker container:
  
    * The WM starts on port 8001
    * A WMP is started on port 9001, intercepting requests that would normally be sent by clients to the WM, and converting them to messages that are sent to the RMQ server
    * The RabbitMQ message consumer is configured to still pull messages from the usual RMQ server, but send workflow requests to the local WM on port 8001
  
* a) Send N messages to the RMQ server, to start as many workflows on the WM containers.

  ./step4_node1.sh
  
  Note: the parameter NJOBS inside the script defines the total number of messages sent to the RMQ server, i.e. the total number of workflows submitted to all WMs.
  
  After sending the messages, the script monitors the RMQ server untill all messages have been pulled by the RMQ clients inside the WM containers. When the last workflow completes, all output products should be moved to $OODT_ARCHIVE.
  
* b) Alternatively, use a traditional WM client to send workflow requests to port 9001 (either to the Swarm service "oodt-wmgr:9001" or to the local proxy "localhost:9001"):

  ./step4-proxy_node2.sh
  
  Execute the aboe script on one of the worker nodes, thenn monitor the log files located under /var/log on each worker container.
  
* To clean up:
  * Delete the output product: rm -rf $OODT_ARCHIVE/test-workflow/\*
  * Delete the job execution files: rm -rf $OODT_JOBS/\*
  * Delete the Docker services: ./step5_node1.sh
  * Remove workers from the Swarm: ./step6_nodeI.sh (to be executed on each Swarm worker node)
  * Delete the Swarm: ./step7_node1.sh

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

export MANAGER_IP=172.20.5.254

Make note of the special token needed to join the Swarm as a worker node.

Then launch N additional EC2 instances to be Swarm Workers, using the same specificiations as above, except for the following:
* Number of instances = N
* Tag the instances with "Name=Swarm Worker Node"
* When each instance starts up, automatically mount the pre-existing EFS volume, and additionally join the existing Swarm as a worker (use the file SwarmWorkerNode, which needs to be modified for the specific Swarm manager IP address, and the specific Swarm worker token).

# Appendix: How to use RabbitMQ with a generic OODT-0.3 Docker architecture

As demonstrated in this tutorial, the RabbitMQ client/server architecture can be used to effectively mamage submission of workflows to multiple distributed OODT Workflow Managers - effectively replacing the need for the OODT Resource Manager component. To use RMQ with OODT, follow these steps:

* Start a container running the RMQ server image "oodthub/oodt-rabbitmq". This container must be reachable at ports 5672, 15672 by all other containers running RMQ clients (which connect with username and password).

* Inside each WM container, start a RMQ "message consumer" which continuosly connect to the RMQ server, pulling messages from a specic queue. The  RMQ client script must be packaged inside the container, and can be started as follows:

  python rabbitmq_client.py pull <workflow_queue> <max_workflows>
  
  where <workflow_queue> is the name of the RMQ queue to pull messages from, which is equal to the name of the OODT event triggering the workflow; and <max_workflows> is the maximum number of concurrent workflows that can be run inside the local Workflow Manager. That is, the RMQ client keeps pulling messages from the specified queue on the RMQ server until that max limit is reached, then wait for the WM workload to decrease before pulling other messages.
  Note that the RMQ message consumer connects to the RMQ server using the URLs defined in the env variables RABBITMQ_USER_URL and RABBITMQ_ADMIN_URL.

* Submit workflows by using a RMQ "message producer" which sends messages to the RMQ server, containing all the medadata necessary to execute a specific workflow. Typically, a small client can be written (see for example test_workflow_driver.py) that inserts all the necessary metadata in a Python dictionary, and then uses the rabbitmq_producer.py module which is packaged with the RMQ or WM containers. Once again, the RMQ message producer will connect to the RMQ server using the connection information specified in the two env variables RABBITMQ_USER_URL and RABBITMQ_ADMIN_URL.
