#!/bin/bash
function test_feature {
  PLATFORM=""
  if [ "$ARCH" != "linux/amd64" ]; then
    PLATFORM="--platform $ARCH"
  fi

  # Copy compiled files from container to allow docker-in-docker via socket
  if [[ $ENVIRONMENT == jdk* ]]; then
    CONTAINER_ID=$(docker create bscdataclay/continuous-integration:testing-$ENVIRONMENT)
    docker cp $CONTAINER_ID:/testing/target $PWD/target
    docker rm $CONTAINER_ID
  fi

  # Config.json could be mounted from outside docker, copy it to avoid re-mounting a volume dir
  cat ${HOME}/.docker/config.json > $PWD/dockercfg.json
  set +e
  docker run $PLATFORM \
    -e HOST_PWD=$PWD \
    -e HOST_USER_ID=$(id -u) \
    -e HOST_GROUP_ID=$(id -g) \
    -e DEBUG=$DEBUG \
    -v $PWD/dockercfg.json:/root/.docker/config.json:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/resources:/testing/resources:ro \
    -v $PWD/features:/testing/features:ro \
    -v $PWD/allure-results:/testing/allure-results:rw \
    -v $PWD/stubs:/testing/stubs:rw \
    bscdataclay/continuous-integration:testing-$ENVIRONMENT $TESTNAME $ENVIRONMENT $ARCH $IMAGE
  return $?
}

function prepare_docker {
  printf "Preparing multiarch... "
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes >/dev/null
  printf "Done! \n"
}

function clean {
  rm -rf $PWD/stubs
  rm -rf $PWD/target
  rm -f $PWD/dockercfg.json
}
echo "WARNING: If you are running tests in local, do NOT run them in parallel, shared volumes could end up into inconsistent status,
use test_all scripts instead or docker containers"
if [ "$#" -lt 4 ]; then
    echo "ERROR: missing parameter. Usage $0 TESTNAME ENVIRONMENT ARCH IMAGE DEBUG where:"
    echo " ARCH = (linux/amd64, linux/arm/v7, linux/arm64)"
    echo " IMAGE = (normal, slim, alpine)"
    echo " ENVIRONMENT = (jdk8, jdk11, py36, py37, py38)"
    echo " DEBUG = (True, False)"
    exit 1
fi
mkdir -p allure-results
SECONDS=0
TESTNAME=$1
ENVIRONMENT=$2
ARCH=$3
IMAGE=$4
DEBUG=False
if [ "$#" -gt 4 ]; then
  DEBUG=$5
fi
prepare_docker
clean
test_feature
EXIT_CODE=$?
clean
echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
echo " Test finished! "
exit $EXIT_CODE
