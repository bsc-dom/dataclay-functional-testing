#!/bin/bash
#==============================================================================
grn=$'\e[1;32m'
blu=$'\e[1;34m'
red=$'\e[1;91m'
yellow=$'\e[1;33m'
end=$'\e[0m'
function printMsg() { echo "${blu}$1${end}"; }
function printInfo() { echo "${blu}$1${end}"; }
function printWarn() { echo "${yellow}WARNING: $1${end}"; }
function printError() { echo "${red}======== $1 ========${end}"; }
#=== FUNCTION ================================================================
# NAME: test_feature
# DESCRIPTION: Test feature
#=============================================================================
function test_feature {
    # Copy compiled files from container to allow docker-in-docker via socket
  if [[ $ENVIRONMENT == jdk* ]]; then
    echo "Copying target from dom-ci.bsc.es/bscdataclay/continuous-integration:testing-$ENVIRONMENT"
    CONTAINER_ID=$(docker create --platform $PLATFORM dom-ci.bsc.es/bscdataclay/continuous-integration:testing-$ENVIRONMENT)
    docker cp $CONTAINER_ID:/testing/target .
    docker rm $CONTAINER_ID
  fi

  # Clean dirs
  pushd ./resources
  for d in $(find . -name 'docker-compose*'); do
    echo "Creating /tmp/dataClay/functional-testing/storage/$(dirname $d) directory"
    mkdir -p /tmp/dataClay/functional-testing/storage/$(dirname $d)
    rm -rf /tmp/dataClay/functional-testing/storage/$(dirname $d)/*
  done
  popd


  set +e
  docker network create dataclay-testing-network
  COMMAND="docker run --rm --platform $PLATFORM \
    --network dataclay-testing-network \
    -e HOST_PWD=$PWD \
    -e HOST_USER_ID=$(id -u) \
    -e HOST_GROUP_ID=$(id -g) \
    -e DEBUG=$DEBUG \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /tmp/dataClay/functional-testing/storage/:/testing/storage:rw \
    -v $PWD/resources:/testing/resources:ro \
    -v $PWD/features:/testing/features:ro \
    -v $PWD/allure-results:/testing/allure-results:rw \
    -v $PWD/stubs:/testing/stubs:rw \
    dom-ci.bsc.es/bscdataclay/continuous-integration:testing-$ENVIRONMENT $TEST $ENVIRONMENT $PLATFORM $IMAGE_TYPE \"$CUCUMBER_OPTIONS\""
  echo $COMMAND
  n=0
  until [ "$n" -ge 2 ]
  do
     # time out 3 hours and retry
     timeout 10800 bash -c "$COMMAND"
     RESULT=$?
     # Retry if timed out
     if [[ $RESULT == 124 ]]; then
       # clean previous tests
       docker rm -f $(docker ps | grep dom-ci | awk '{print $1}')
       # wait for sockets to close
       sleep 120
     else
       break
     fi
     n=$((n+1))
  done
  docker network rm dataclay-testing-network
  return $RESULT
}

#=== FUNCTION ================================================================
# NAME: docker_pull
# DESCRIPTION: Pull from DockerHub and retry if connection fails
#=============================================================================
function docker_pull {
  PULL_IMAGE=$1
  n=0
  until [ "$n" -ge 20 ] # Retry maximum 20 times
  do
      CMD="docker pull --platform $PLATFORM $PULL_IMAGE"
      printInfo "$CMD"
      docker pull --platform $PLATFORM $PULL_IMAGE && break
      n=$((n+1))
      sleep 15
  done
  if [ "$n" -eq 20 ]; then
    echo "ERROR: $PULL_IMAGE could not be pulled"
    exit 1
  fi
  echo "$PULL_IMAGE Image pulled (in $n retries) *************"
}

#=== FUNCTION ================================================================
# NAME: prepare_images
# DESCRIPTION: Prepare docker images to be used in test
#=============================================================================
function prepare_images {
  IMAGE_TAG=""
  if [[ $IMAGE_TYPE != "normal" ]]; then
    IMAGE_TAG="-$IMAGE_TYPE"
  fi
  # PULL ALL IMAGES
  if [[ $ENVIRONMENT == jdk* ]]; then
    docker_pull dom-ci.bsc.es/bscdataclay/logicmodule:develop.${ENVIRONMENT}${IMAGE_TAG}
    docker_pull dom-ci.bsc.es/bscdataclay/dsjava:develop.${ENVIRONMENT}${IMAGE_TAG}
    docker_pull dom-ci.bsc.es/bscdataclay/dspython:develop${IMAGE_TAG}
  else
    docker_pull dom-ci.bsc.es/bscdataclay/logicmodule:develop${IMAGE_TAG}
    docker_pull dom-ci.bsc.es/bscdataclay/dsjava:develop${IMAGE_TAG}
    docker_pull dom-ci.bsc.es/bscdataclay/dspython:develop.${ENVIRONMENT}${IMAGE_TAG}
  fi
  docker_pull dom-ci.bsc.es/bscdataclay/client:develop${IMAGE_TAG}
  docker_pull dom-ci.bsc.es/bscdataclay/continuous-integration:testing-$ENVIRONMENT
  printf "Done! \n"
}
################################## Main ####################################
set -e
printWarn "Do NOT run tests in parallel, shared volumes could end up into inconsistent status"
printInfo "Usage: $0 [--tests \"mytest.feature othertest.feature\"] [--environments \"py37 jdk11\"] [--image-types \"alpine\"] \
  [--platforms \"linux/amd64\"] [--debug] "

DEBUG=False
SPECIFIED_TESTS=false
CUCUMBER_OPTIONS=""
TEST_PATTERN="*"
USE_LOCAL_IMAGES=false
source ./BUILD_MATRIX.txt
TESTS=()

while test $# -gt 0; do
  case "$1" in
  --local)
    USE_LOCAL_IMAGES=true
    PLATFORMS=(linux/amd64)
    printWarn "Using local images in linux/amd64"
    ;;
  --debug)
    DEBUG=True
    printWarn "Debug enabled"
    ;;
  --cucumber-opts)
    shift
    CUCUMBER_OPTIONS=$1
    printWarn "Cucumber options provided: $CUCUMBER_OPTIONS"
    ;;
  --debug-tag)
    shift
    DEBUG=True
    DEBUG_TAG=$1
    printWarn "Running tests with tag: $DEBUG_TAG"
    ;;
  --test-pattern)
    shift
    TEST_PATTERN=$1
    printWarn "Using test pattern: $TEST_PATTERN"
    ;;
  --tests)
    shift
    SPECIFIED_TESTS=true
    IFS=' ' read -r -a TESTS <<< "$1"
    ;;
  --environments-with-prefix)
    shift
    ENVIRONMENTS_WITH_PREFIX=$1
    printWarn "Only testing environments with prefix: $ENVIRONMENTS_WITH_PREFIX"
    NEW_ENVIRONMENTS=()
    for ENV in "${ENVIRONMENTS[@]}"; do
      echo "checking $ENV"
      if [[ $ENV == ${ENVIRONMENTS_WITH_PREFIX}* ]]; then
        NEW_ENVIRONMENTS+=(${ENV})
      fi
    done
    ENVIRONMENTS=()
    for ENV in ${NEW_ENVIRONMENTS[@]}; do
      ENVIRONMENTS+=(${ENV})
    done
    ;;
  --environments)
    shift
    IFS=' ' read -r -a ENVIRONMENTS <<< "$1"
    ;;
  --image-types)
    shift
    IFS=' ' read -r -a IMAGE_TYPES <<< "$1"
    ;;
  --platforms)
    shift
    IFS=' ' read -r -a PLATFORMS <<< "$1"
    ;;
  *)
    echo "Bad option $1"
    exit 1
    ;;
  esac
  shift
done
if [ $SPECIFIED_TESTS == false ]; then
  pushd ./features/
  for f in $TEST_PATTERN.feature; do
      FEATURE="${f}"
      TESTS+=(${FEATURE})
  done
  popd
fi


TESTS_STR=""
for element in "${TESTS[@]}"; do
    TESTS_STR="$element $TESTS_STR"
done
ENVIRONMENTS_STR=""
for element in "${ENVIRONMENTS[@]}"; do
    ENVIRONMENTS_STR="$element $ENVIRONMENTS_STR"
done
PLATFORMS_STR=""
for element in "${PLATFORMS[@]}"; do
    PLATFORMS_STR="$element $PLATFORMS_STR"
done
IMAGES_TYPES_STR=""
for element in "${IMAGE_TYPES[@]}"; do
    IMAGES_TYPES_STR="$element $IMAGES_TYPES_STR"
done
printWarn "Tests: $TESTS_STR"
printWarn "Environments to test: $ENVIRONMENTS_STR"
printWarn "Platforms to test: $PLATFORMS_STR"
printWarn "Image types to test: $IMAGES_TYPES_STR"
mkdir -p allure-results
SECONDS=0

for PLATFORM in "${PLATFORMS[@]}"; do
  for ENVIRONMENT in "${ENVIRONMENTS[@]}"; do

      if [ ! -z ${DEBUG_TAG+x} ]; then
        if [[ $ENVIRONMENT == jdk* ]]; then
          CUCUMBER_OPTIONS="-Dcucumber.filter.tags=\"@${DEBUG_TAG}\""
        else
          CUCUMBER_OPTIONS="--tags=@${DEBUG_TAG}"
        fi
      fi

      for IMAGE_TYPE in "${IMAGE_TYPES[@]}"; do
        if [ "$IMAGE_TYPE" == "arm32" ] && [ "$PLATFORM" != "linux/arm/v7" ]; then
          printWarn "WARNING: Arm32 images can only use linux/arm/v7 platform, skipping"
          continue
        fi
        if [ "$IMAGE_TYPE" == "alpine" ] && [ "$PLATFORM" == "linux/arm/v7" ]; then
          printWarn "WARNING: Alpine images have no support for linux/arm/v7 platform, skipping"
          continue
        fi
        for TEST in "${TESTS[@]}"; do
          printInfo "***** Going to test $TEST in platform=$PLATFORM environment=$ENVIRONMENT and image type=$IMAGE_TYPE  **** "
          if [ $USE_LOCAL_IMAGES == false ]; then
            prepare_images
          fi

          test_feature
          RESULT=$?
          if [ $RESULT -ne 0 ]; then
              EXIT_CODE=$RESULT
          fi
        done
      done
    done
done

echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
echo "Tests finished! "
exit $EXIT_CODE
