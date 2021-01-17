#!/bin/bash
source ./BUILD_MATRIX.txt
rm -rf ./allure-results
mkdir -p ./allure-results
TESTS=()
pushd ./features/
for f in *.feature; do
    FEATURE="${f%.feature}"
    printf '%s\n' "${FEATURE}"
    TESTS+=(${FEATURE})
done
popd
EXIT_CODE=0
for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
    for ARCH in ${ARCHS[@]}; do
      for IMAGE in ${IMAGES[@]}; do
        for TEST in ${TESTS[@]}; do
          ./test_feature.sh $TEST $ENVIRONMENT $ARCH $IMAGE
          RESULT=$?
          if [ $?RESULT -ne 0 ]; then
              EXIT_CODE=$RESULT
          fi
        done
      done
    done
done

exit $EXIT_CODE