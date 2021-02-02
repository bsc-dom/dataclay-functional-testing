#!/bin/bash
if [ "$#" -ne 4 ]; then
    echo "ERROR: missing parameter. Usage $0 TEST_PATTERN ENVIRONMENT IMAGE ARCH"
    exit 1
fi
TEST_PATTERN=$1
TESTS=()
pushd ./features/
for f in $TEST_PATTERN.feature; do
    FEATURE="${f%.feature}"
    printf '%s\n' "${FEATURE}"
    TESTS+=(${FEATURE})
done
popd
mkdir -p ./allure-results
ENVIRONMENT=$2
IMAGE=$3
ARCH=$4
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


