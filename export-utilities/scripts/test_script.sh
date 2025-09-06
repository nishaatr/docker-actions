#!/usr/bin/env bash

SOURCES="$1"

source /dev/stdin <<< "$(echo ${SOURCES} | base64 --decode)"

echonotice "I am running test-utils.sh"
echowarning "I am running test-utils.sh"
log_header "Tests HEADER in test-utils.sh"
my_func1
my_func2