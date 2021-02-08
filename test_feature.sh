#!/bin/bash
function test_feature {
  # Copy compiled files from container to allow docker-in-docker via socket
  if [[ $ENVIRONMENT == jdk* ]]; then
    CONTAINER_ID=$(docker create --platform $ARCH bscdataclay/continuous-integration:testing-$ENVIRONMENT)
    docker cp $CONTAINER_ID:/testing/target $PWD/target
    docker rm $CONTAINER_ID
  fi

  # Config.json could be mounted from outside docker, copy it to avoid re-mounting a volume dir
  cat ${HOME}/.docker/config.json > $PWD/dockercfg.json
  set +e
  COMMAND="docker run --platform $ARCH \
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
    bscdataclay/continuous-integration:testing-$ENVIRONMENT $TESTNAME $ENVIRONMENT $ARCH $IMAGE"
  echo $COMMAND
  eval $COMMAND
  return $?
}

#=== FUNCTION ================================================================
# NAME: docker_pull
# DESCRIPTION: Pull from DockerHub and retry if connection fails
#=============================================================================
function docker_pull {
  PULL_IMAGE=$1
  n=0
  if [[ "$(docker images -q $PULL_IMAGE 2> /dev/null)" == "" ]]; then
    until [ "$n" -ge 20 ] # Retry maximum 20 times
    do
      echo "Pulling image $PULL_IMAGE (retry $n)"
      docker pull --platform $ARCH $PULL_IMAGE && break
      n=$((n+1))
      sleep 15
    done
    if [ "$n" -eq 20 ]; then
      echo "ERROR: $PULL_IMAGE could not be pulled"
      exit 1
    fi
    echo "$PULL_IMAGE Image pulled (in $n retries) *************"
  else
    echo "$PULL_IMAGE already exists"
  fi
}

function prepare_docker {
  printf "Preparing multiarch... "
  #docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64 >/dev/null
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes >/dev/null
}

function prepare_images {
  IMAGE_TAG=""
  if [[ $IMAGE != "normal" ]]; then
    IMAGE_TAG="-$IMAGE"
  fi

  # PULL ALL IMAGES if not present
  if [[ $ENVIRONMENT == jdk* ]]; then
    docker_pull bscdataclay/logicmodule:develop.${ENVIRONMENT}${IMAGE_TAG}
    docker_pull bscdataclay/dsjava:develop.${ENVIRONMENT}${IMAGE_TAG}
    docker_pull bscdataclay/dspython:develop${IMAGE_TAG}
  else
    docker_pull bscdataclay/logicmodule:develop${IMAGE_TAG}
    docker_pull bscdataclay/dsjava:develop${IMAGE_TAG}
    docker_pull bscdataclay/dspython:develop.${ENVIRONMENT}${IMAGE_TAG}
  fi
  docker_pull bscdataclay/client:develop${IMAGE_TAG}
  docker_pull bscdataclay/continuous-integration:testing-$ENVIRONMENT
  docker_pull linuxserver/docker-compose:latest
  printf "Done! \n"
}

function clean {
  #rm -rf $PWD/stubs
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
prepare_images
clean
test_feature
EXIT_CODE=$?
clean
echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
echo " Test finished! "
exit $EXIT_CODE
