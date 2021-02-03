#!/bin/bash
if [ "$#" -ne 4 ]; then
    echo "ERROR: missing parameter. Usage $0 ARCH ENVIRONMENT IMAGE TEST_PATTERN"
    exit 1
fi
ARCH=$1
ENVIRONMENT=$2
IMAGE=$3
TEST_PATTERN=$4
TESTS=()
pushd ./features/
for f in $TEST_PATTERN.feature; do
    FEATURE="${f%.feature}"
    printf '%s\n' "${FEATURE}"
    TESTS+=(${FEATURE})
done
popd
mkdir -p ./allure-results
EXIT_CODE=0
echo "Going to test: ${TESTS[@]} "
for TEST in ${TESTS[@]}; do
    ./test_feature.sh $TEST $ENVIRONMENT $ARCH $IMAGE
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        EXIT_CODE=$RESULT
    fi
done
exit $EXIT_CODE


