#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "ERROR: missing parameter. Usage $0 TESTNAME"
    exit 1
fi
source ./BUILD_MATRIX.txt
mkdir -p ./allure-results
TEST=$1
EXIT_CODE=0
for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
    for ARCH in ${ARCHS[@]}; do
      for IMAGE in ${IMAGES[@]}; do
          ./test_feature.sh $TEST $ENVIRONMENT $ARCH $IMAGE
          RESULT=$?
          if [ $RESULT -ne 0 ]; then
              EXIT_CODE=$RESULT
          fi
      done
    done
done
exit $EXIT_CODE
