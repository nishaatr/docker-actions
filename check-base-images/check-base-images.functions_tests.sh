#!/usr/bin/env bash

set -eu ${RUNNER_DEBUG:+-x}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Source the latest version of assert.sh unit testing library and include in current shell
source /dev/stdin <<< "$(curl --silent https://raw.githubusercontent.com/hazelcast/assert.sh/main/assert.sh)"

. "$SCRIPT_DIR"/check-base-images.functions.sh

TESTS_RESULT=0

function assert_base_image_outdated {
  local current_image=$1
  local base_image=$2
  local expected_exit_code=$3
  base_image_outdated "${current_image}" "${base_image}" && true
  local actual_exit_code=$?
  local msg="Expected exit code for \"${current_image}\" compared to \"${base_image}\""
  assert_eq "${expected_exit_code}" "${actual_exit_code}" "${msg}" && log_success "${msg}" || TESTS_RESULT=$?
}

function assert_packages_updatable {
  local image=$1
  local base_image=$2
  local expected_exit_code=$3
  packages_updatable "${image}" "${base_image}" && true
  local actual_exit_code=$?
  local msg="Expected exit code for image \"${image}\""
  assert_eq "${expected_exit_code}" "${actual_exit_code}" "${msg}" && log_success "${msg}" || TESTS_RESULT=$?
}

log_header "Tests for packages_updatable"
assert_packages_updatable hazelcast/hazelcast:5.0.1-slim alpine:3.15.0  0
assert_packages_updatable hazelcast/hazelcast-enterprise:5.0.1-slim redhat/ubi8-minimal:8.5 0
# Cannot guarantee the latest upstream image is fully updated
# assert_packages_updatable alpine:latest alpine:latest 1
# assert_packages_updatable redhat/ubi9-minimal:latest redhat/ubi9-minimal:latest 1

log_header "Tests for base_image_outdated"
assert_base_image_outdated alpine:latest alpine:latest 1
assert_base_image_outdated hazelcast/hazelcast:5.0.1-slim alpine:latest 0

assert_eq 0 "$TESTS_RESULT" "All tests should pass"
