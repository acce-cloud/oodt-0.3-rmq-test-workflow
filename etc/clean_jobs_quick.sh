#!/bin/bash

OODT_ARCHIVE=/shared_data/oodt-data/archive
OODT_JOBS=/shared_data/oodt-data/pges/test-workflow/jobs
OODT_LOGS=/shared_data/oodt-data/logs

sudo rm -rf ${OODT_ARCHIVE}/*
sudo rm -rf ${OODT_JOBS}/*
sudo rm -rf ${OODT_LOGS}/*
