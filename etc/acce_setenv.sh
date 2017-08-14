# sets the environment variables for the ACCE cluster
export MANAGER_IP=172.31.4.166

export OODT_CONFIG=/usr/local/adeploy/test/src/oodt-0.3-rmq-test-workflow
mkdir -p $OODT_CONFIG
export OODT_ARCHIVE=/usr/local/adeploy/test/archive
mkdir -p $OODT_ARCHIVE 
export OODT_JOBS=/usr/local/adeploy/test/pges/test-workflow/jobs
mkdir -p $OODT_JOBS
