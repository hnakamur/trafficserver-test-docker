#!/bin/bash

# Example usage:
# run-trafficserver-test.sh list
# run-trafficserver-test.sh run
# run-trafficserver-test.sh run -f hello_lua

set -e

mkdir -p ~build/logs

(cd ~build/dev/trafficserver/tests \
 && echo "=== test target trafficserver git commit ===" \
 && git log -1 \
 && . env-test/bin/activate \
 && echo "" \
 && echo "=== test results ===" \
 && env-test/bin/autest $* -D gold_tests --ats-bin /usr/bin) \
 | tee ~build/logs/trafficserver-test-$(date +%Y%m%d-%H%M).log
