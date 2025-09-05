#!/usr/bin/env bash

UTILS_PATH=$1

source <(cat ${UTILS_PATH}/*.sh)

echonotice "I am running test-export-utils.sh"
echowarning "I am running test-export-utils.sh"
log_header "Tests HEADER in test-export-utils.sh"
my_func1
my_func2