#!/bin/bash
if [ "$#" -ne 4 ]; then
    echo "ERROR: missing parameter. Usage $0 ENVIRONMENT ARCH IMAGE"
    exit 1
fi
TESTS=()
pushd ./features/
for f in *.feature; do
    FEATURE="${f%.feature}"
    printf '%s\n' "${FEATURE}"
    TESTS+=(${FEATURE})
done
popd
mkdir -p ./allure-results
ENVIRONMENT=$1
ARCH=$2
IMAGE=$3
EXIT_CODE=0
for TEST in ${TESTS[@]}; do
    ./test_feature.sh $TEST $ENVIRONMENT $ARCH $IMAGE
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        EXIT_CODE=$RESULT
    fi
done
exit $EXIT_CODE


