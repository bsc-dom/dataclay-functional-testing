#!/bin/bash -e
#===================================================================================
#
# FILE: deploy.sh
#
# USAGE: deploy.sh [--dev]
#
# DESCRIPTION: Deploy dataClay testing dockers into testing registry
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: dgasull@bsc.es
# COMPANY: Barcelona Supercomputing Center (BSC)
# VERSION: 1.0
#===================================================================================
#==============================================================================
grn=$'\e[1;32m'
blu=$'\e[1;34m'
red=$'\e[1;91m'
yellow=$'\e[1;33m'
end=$'\e[0m'
function printMsg() { echo "${blu}$1${end}"; }
function printInfo() { echo "${yellow}$1${end}"; }
function printWarn() { echo "${yellow}WARNING: $1${end}"; }
function printError() { echo "${red}======== $1 ========${end}"; }
#=== FUNCTION ================================================================
# NAME: deploy
# DESCRIPTION: Deploy to DockerHub and retry if connection fails
#=============================================================================
function deploy {
  SECONDS=0
  COMMAND=""
  while [[ $# -gt 0 ]]; do
    param="$1"
    case $param in
    -t)
      IMAGE_NAME="$2"
      COMMAND+="$1 $2 "
      shift # past argument
      shift # past value
      ;;
    *) # unknown option
      COMMAND+="$1 "
      shift # past argument
      ;;
    esac
  done
  export n=0
  until [ "$n" -ge 5 ]; do # Retry maximum 5 times
    printMsg "************* Pushing/building image $IMAGE_NAME (retry $n) *************"
    printMsg "$COMMAND"
    eval "$COMMAND" && break
    n=$((n + 1))
    sleep 15
  done
  if [ "$n" -eq 5 ]; then
    printError "ERROR: $IMAGE_NAME could not be pushed"
    return 1
  fi

  printMsg "************* $IMAGE_NAME IMAGE done! (in $n retries) *************"
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
}
#=== FUNCTION ================================================================
# NAME: prepare_docker_buildx
# DESCRIPTION: Prepare docker buildx and check
#=============================================================================
function prepare_docker_buildx {
  printf "Checking if docker version >= $REQUIRED_DOCKER_VERSION..."
  version=$(docker version --format '{{.Server.Version}}')
  if [[ "$version" < "$REQUIRED_DOCKER_VERSION" ]]; then
    echo "ERROR: Docker version is less than $REQUIRED_DOCKER_VERSION"
    exit 1
  fi
  printf "OK\n"
  # Check if already exists
  echo "Checking builder dataclay-builderx"
  RESULT=$(docker buildx ls)
  if [[ $RESULT == *"dataclay-builderx"* ]]; then
    echo "Using already existing builder dataclay-builderx"
    docker buildx use dataclay-builderx
  else
    echo "Creating builder $BUILDERX_NAME"
    # prepare architectures
    docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
    #docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker run --rm -t arm64v8/ubuntu uname -m
    docker buildx create --driver-opt network=host --name dataclay-builderx
    docker buildx use dataclay-builderx
    echo "Checking buildx with available platforms to simulate..."
    docker buildx inspect --bootstrap
    if [ -f "/usr/local/share/ca-certificates/dom-ci.bsc.es.crt" ]; then
      echo "Copying certificate /usr/local/share/ca-certificates/dom-ci.bsc.es.crt to docker buildx"
      BUILDER=$(docker ps | grep buildkitd | cut -f1 -d' ')
      docker cp /usr/local/share/ca-certificates/dom-ci.bsc.es.crt $BUILDER:/usr/local/share/ca-certificates/
      docker exec $BUILDER update-ca-certificates
      docker restart $BUILDER
    fi
  fi
}
#=== FUNCTION ================================================================
# NAME: deploy_testing_image
# DESCRIPTION: Deploy testing image
#=============================================================================
function deploy_testing_image {
  IMAGE_NAME=$1
  DOCKERFILE=$2
  PREFIX=$(sed -e 's/[0-9]*$//' <<< "$ENVIRONMENT")
  ENVIRONMENT_VERSION=$(grep -o '[0-9].*' <<< "$ENVIRONMENT")
  PLATFORMS_COMMAND="--platform $PLATFORMS_ARG"
  if [ $LOCAL == true ]; then
    PLATFORMS_COMMAND=""
  fi
  IMAGE_DC=""
  if [ "${IMAGE_TYPES[0]}" != "normal" ]; then
    IMAGE_DC="-${IMAGE_TYPES[0]}"
  fi
  if [ "$PREFIX" == "jdk" ]; then
    # prepare javaclay jar, retrieve it from some of the image types provided
    echo "Retrieving dataClay.jar from dom-ci.bsc.es/bscdataclay/dsjava:develop${IMAGE_DC} image "
    CONTAINER_ID=$(docker create dom-ci.bsc.es/bscdataclay/dsjava:develop${IMAGE_DC})
    docker cp $CONTAINER_ID:/home/dataclayusr/dataclay/dataclay.jar $PWD/dataclay.jar
    docker rm $CONTAINER_ID
    printMsg "Building and compiling javaclay functional tests"
    # build local changes in javaclay testing, pyclay just mount it but here we need to compile
    docker build -f packager.jdk.Dockerfile -t dom-ci.bsc.es/bscdataclay/continuous-integration:javaclay-jar .
    JAVACLAY_CONTAINER=$(docker create --rm  dom-ci.bsc.es/bscdataclay/continuous-integration:javaclay-jar)
    docker cp $JAVACLAY_CONTAINER:/testing/target/ ./testing-target
    docker rm $JAVACLAY_CONTAINER
  fi

  deploy docker $DOCKER_BUILDX_COMMAND build --rm -f ${PREFIX}.${DOCKERFILE} -t $IMAGE_NAME \
           --build-arg ENVIRONMENT=$ENVIRONMENT \
           --build-arg ENVIRONMENT_VERSION=$ENVIRONMENT_VERSION \
           --build-arg IMAGE_DC=${IMAGE_DC} \
           $PLATFORMS_COMMAND $DOCKER_PROGRESS \
           $DOCKER_COMMAND .
}

################################## Main ####################################
set -e
DOCKERFILE=""
DOCKER_PROGRESS=""
DOCKER_COMMAND="--push"
DOCKER_BUILDX_COMMAND="buildx"

source ./BUILD_MATRIX.txt

LOCAL=false
DEPLOY_BASE=false

while test $# -gt 0; do
  case "$1" in
  --build)
    # local build
    LOCAL=true
    DOCKER_BUILDX_COMMAND=""
    DOCKER_COMMAND=""
    PLATFORMS=(linux/amd64)
    printWarn "Build in local docker"
    ;;
  --deploy-base)
    DEPLOY_BASE=true
    ;;
  --skip-base)
    DEPLOY_BASE=false
    ;;
  --image-types)
    shift
    IFS=' ' read -r -a IMAGE_TYPES <<< "$1"
    ;;
  --environments)
    shift
    IFS=' ' read -r -a ENVIRONMENTS <<< "$1"
    ;;
  --platforms)
    shift
    IFS=' ' read -r -a PLATFORMS <<< "$1"
    ;;
  --plain)
    DOCKER_PROGRESS="--progress plain"
    ;;
  *)
    echo "Bad option $1"
    exit 1
    ;;
  esac
  shift
done
###############################################################################

#GIT_BRANCH=$(git for-each-ref --format='%(objectname) %(refname:short)' refs/heads | awk "/^$(git rev-parse HEAD)/ {print \$2}")
#if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
#  printError "Branch is not $BRANCH_TO_CHECK. Found $GIT_BRANCH. Aborting script"
#  exit 1
#fi
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
printMsg "*** Welcome to dataClay deploy for testing!"
printWarn "Deploying testing dockers for environments: $ENVIRONMENTS_STR"
printWarn "Deploying testing dockers for platforms: $PLATFORMS_STR"
printWarn "Deploying testing dockers for image types: $IMAGES_TYPES_STR"
prepare_docker_buildx
SECONDS=0
printf -v PLATFORMS_ARG '%s,' "${PLATFORMS[@]}"
PLATFORMS_ARG="${PLATFORMS_ARG%,}"

if [ $DEPLOY_BASE == true ]; then
  for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
    deploy_testing_image dom-ci.bsc.es/bscdataclay/continuous-integration:testing-$ENVIRONMENT-base base.Dockerfile
  done
fi

for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
  deploy_testing_image dom-ci.bsc.es/bscdataclay/continuous-integration:testing-$ENVIRONMENT Dockerfile
done
rm -rf $PWD/testing-target
rm -f $PWD/dataclay.jar

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "dataClay deployment FINISHED! "
