#!/bin/bash
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
        IMAGE="$2"
        COMMAND+="$1 $2 "
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        COMMAND+="$1 "
        shift # past argument
        ;;
    esac
  done
  echo "$COMMAND"
  export n=0
  until [ "$n" -ge 5 ] # Retry maximum 5 times
  do
    echo "************* Pushing image $IMAGE (retry $n) *************"
    eval "$COMMAND" && break
    n=$((n+1))
    sleep 15
  done
  if [ "$n" -eq 5 ]; then
    echo "ERROR: $IMAGE could not be pushed"
    return 1
  fi

  echo "************* $IMAGE IMAGE PUSHED! (in $n retries) *************"
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
}
#=============================================================================
if [ "$#" -ne 4 ]; then
    echo "ERROR: missing parameter. Usage ./deploy.sh IMAGE_NAME DOCKER_FILE ENVIRONMENT ARCH where:"
    echo " ARCH = (linux/amd64, linux/arm/v7, linux/arm64)"
    echo " ENVIRONMENT = (jdk8, jdk11, py36, py37, py38)"
    exit 1
fi
IMAGE_NAME=$1
DOCKER_FILE=$2
ENVIRONMENT=$3
PREFIX=$(sed -e 's/[0-9]*$//' <<< "$ENVIRONMENT")
ENVIRONMENT_VERSION=$(grep -o '[0-9].*' <<< "$ENVIRONMENT")

# Check if already exists
echo "Checking builder dataclay-builderx"
RESULT=$(docker buildx ls)
if [[ $RESULT == *"dataclay-builderx"* ]]; then
  echo "Using already existing builder dataclay-builderx"
  docker buildx use dataclay-builderx
else
  echo "Creating builder $BUILDERX_NAME"
  docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
  docker buildx create --name dataclay-builderx
  docker buildx use dataclay-builderx
  docker buildx inspect --bootstrap
fi

docker build -f packager.jdk.Dockerfile -t bscdataclay/continuous-integration:javaclay-jar .
JAVACLAY_CONTAINER=$(docker create --rm  bscdataclay/continuous-integration:javaclay-jar)
docker cp $JAVACLAY_CONTAINER:/testing/target/ ./testing-target
docker rm $JAVACLAY_CONTAINER

deploy docker buildx build -f $PREFIX.$DOCKER_FILE -t $IMAGE_NAME \
           --build-arg ENVIRONMENT=$ENVIRONMENT \
           --build-arg REGISTRY=bscdataclay \
           --build-arg ENVIRONMENT_VERSION=$ENVIRONMENT_VERSION \
           --platform $PLATFORMS \
           --push .
RESULT=$?
if [ $RESULT -ne 0 ]; then
   exit 1
fi
rm -rf ./testing-target
echo " ===== Done! ====="