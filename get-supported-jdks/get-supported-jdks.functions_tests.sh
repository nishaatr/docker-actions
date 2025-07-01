#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

source /dev/stdin <<< "$(curl --silent https://raw.githubusercontent.com/hazelcast/assert.sh/main/assert.sh)"

. "$SCRIPT_DIR"/get-supported-jdks.functions.sh

TESTS_RESULT=0

function assert_version_less_or_equal {
  local VERSION1=$1
  local VERSION2=$2
  local EXPECTED=$3
  local MSG="$VERSION1 should$([ "$EXPECTED" = "true" ] || echo " NOT") be less than or equal to $VERSION2"
  local RESULT

  version_less_or_equal "$VERSION1" "$VERSION2" && RESULT=true || RESULT=false
  assert_eq "$RESULT" "$EXPECTED" "$MSG" && log_success "$MSG" || TESTS_RESULT=$?
}

function assert_version_less_than {
  local VERSION1=$1
  local VERSION2=$2
  local EXPECTED=$3
  local MSG="$VERSION1 should$([ "$EXPECTED" = "true" ] || echo " NOT") less than $VERSION2"
  local RESULT

  version_less_than "$VERSION1" "$VERSION2" && RESULT=true || RESULT=false
  assert_eq "$RESULT" "$EXPECTED" "$MSG" && log_success "$MSG" || TESTS_RESULT=$?
}

function assert_get_supported_jdks {
  local HZ_VERSION=$1
  local EXPECTED=$2
  local MSG="JDK"

  local MSG="$VERSION1 should$([ "$EXPECTED" = "true" ] || echo " NOT") less than $VERSION2"
  local RESULT

  version_less_than "$VERSION1" "$VERSION2" && RESULT=true || RESULT=false
  assert_eq "$RESULT" "$EXPECTED" "$MSG"  && log_success "$MSG" || TESTS_RESULT=$?
}

log_header "Tests for version_less_or_equal"
assert_version_less_or_equal "3.9.4" "4.0.0" "true"
assert_version_less_or_equal "4.1.10" "4.2.1" "true"
assert_version_less_or_equal "5.3.1" "5.3.2" "true"
assert_version_less_or_equal "3.12.11" "3.12.12" "true"

assert_version_less_or_equal "4.2.8" "4.2.8" "true"
assert_version_less_or_equal "5.10.0" "5.10.0" "true"
assert_version_less_or_equal "3.0.0" "3.0.0" "true"
assert_version_less_or_equal "3.0.1" "3.0.1" "true"

assert_version_less_or_equal "4.2.1" "4.1.10" "false"
assert_version_less_or_equal "5.0.0" "4.2.8" "false"
assert_version_less_or_equal "4.2.8" "3.0.0" "false"
assert_version_less_or_equal "5.3.2" "5.3.1" "false"

assert_version_less_or_equal "5.4.0-DEVEL-1" "5.4.0" "true"
assert_version_less_or_equal "5.4.0-DEVEL-1" "5.4.0-DEVEL-1" "true"

log_header "Tests for version_less_than"
assert_version_less_than "3.9.4" "4.0.0" "true"
assert_version_less_than "4.1.10" "4.2.1" "true"
assert_version_less_than "5.3.1" "5.3.2" "true"
assert_version_less_than "3.12.11" "3.12.12" "true"

assert_version_less_than "4.2.8" "4.2.8" "false"
assert_version_less_than "5.10.0" "5.10.0" "false"
assert_version_less_than "3.0.0" "3.0.0" "false"
assert_version_less_than "3.0.1" "3.0.1" "false"

assert_version_less_than "4.2.1" "4.1.10" "false"
assert_version_less_than "5.0.0" "4.2.8" "false"
assert_version_less_than "4.2.8" "3.0.0" "false"
assert_version_less_than "5.3.2" "5.3.1" "false"

assert_version_less_than "4.1.0-BETA-1" "4.1.0" "true"
assert_version_less_than "5.4.0-DEVEL-1" "5.4.0" "true"
assert_version_less_than "5.4.0" "5.4.0-DEVEL-1" "false"

function assert_get_supported_jdks {
  local HZ_VERSION=$1
  local EXPECTED=$2
  local MSG="JDK versions for $HZ_VERSION should be $EXPECTED"
  assert_eq "$(get_supported_jdks "$HZ_VERSION")" "$EXPECTED" "$MSG" && log_success "$MSG" || TESTS_RESULT=$?
}

log_header "Tests for get_supported_jdks"
assert_get_supported_jdks "5.3.9" "['11', '17']"
assert_get_supported_jdks "4.2.8" "['11', '17']"
assert_get_supported_jdks "5.3.99" "['11', '17']"

assert_get_supported_jdks "5.4.0" "['17', '21']"
assert_get_supported_jdks "5.4.1" "['17', '21']"
assert_get_supported_jdks "5.5.0" "['17', '21']"
assert_get_supported_jdks "6.0.0" "['17', '21']"

assert_eq 0 "$TESTS_RESULT" "All tests should pass"
