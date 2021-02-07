#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "ERROR: missing parameter. Usage $0 dataclay-packaging-path"
    exit 1
fi
status_code=$(curl -I -k -s http://localhost:5000/ | head -n 1 | cut -d ' ' -f 2)
if [[ "$status_code" != "200" ]]; then
    echo "ERROR: missing local docker registry. Start it with "
    echo "    docker run -d -p 5000:5000 --restart=always --name registry registry:2 "
    exit 1
fi
DATACLAY_PACKAGING=$1
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
        ./build.sh $DATACLAY_PACKAGING --images $IMAGE --arch $ARCH --environments $ENVIRONMENT
        for TEST in ${TESTS[@]}; do
          ./test_feature.sh $TEST $ENVIRONMENT $ARCH $IMAGE
          RESULT=$?
          if [ $RESULT -ne 0 ]; then
              EXIT_CODE=$RESULT
          fi
        done
      done
    done
done

exit $EXIT_CODE