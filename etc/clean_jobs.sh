#!/bin/bash

OODT_ARCHIVE=/shared_data/oodt-data/archive
OODT_JOBS=/shared_data/oodt-data/pges/test-workflow/jobs
#OODT_LOGS=/shared_data/oodt-data/logs

# data archive
for ((i=1000;i>=1;i--)); do
  echo "Cleaning up ${OODT_ARCHIVE}/test-workflow/output_Run_${i}*"
  sudo rm -rf ${OODT_ARCHIVE}/test-workflow/output_Run_${i}*
  echo "Cleaning up ${OODT_JOBS}/${i}*"
  sudo rm -rf ${OODT_JOBS}/${i}*
done

# jobs
sudo rm -rf ${OODT_JOBS}/a*
sudo rm -rf ${OODT_JOBS}/b*
sudo rm -rf ${OODT_JOBS}/c*
sudo rm -rf ${OODT_JOBS}/d*
sudo rm -rf ${OODT_JOBS}/e*
sudo rm -rf ${OODT_JOBS}/f*
sudo rm -rf ${OODT_JOBS}/*

# logs
#sudo rm -rf ${OODT_LOGS}/*
