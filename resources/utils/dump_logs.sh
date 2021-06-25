#!/bin/bash
# collect logs
FAILED_TESTS_DIR=/failed_tests/
mkdir -p $FAILED_TESTS_DIR
echo "Collecting logs into $FAILED_TESTS_DIR"
for container in $(docker ps | grep dom-ci | awk '{print $12}'); do docker logs $container > $FAILED_TESTS_DIR/$container.log 2>$1 ; done
