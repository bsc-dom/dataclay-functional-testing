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
if [ "$#" -ne 5 ]; then
    echo "ERROR: missing parameter. Usage ./deploy.sh IMAGE_NAME DOCKER_FILE ENVIRONMENT ARCH SHARE_BUILDERX where:"
    echo " ARCH = (linux/amd64, linux/arm/v7, linux/arm64)"
    echo " SHARE_BUILDERX = (true,false)"
    echo " ENVIRONMENT = (jdk8, jdk11, py36, py37, py38)"
    exit 1
fi
IMAGE_NAME=$1
DOCKER_FILE=$2
ENVIRONMENT=$3
PREFIX=$(sed -e 's/[0-9]*$//' <<< "$ENVIRONMENT")
ENVIRONMENT_VERSION=$(grep -o '[0-9].*' <<< "$ENVIRONMENT")
PLATFORMS=$4
SHARE_BUILDERX=$5
if [ "$SHARE_BUILDERX" = "false" ]; then
  docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
  DOCKER_BUILDER=$(docker buildx create)
  docker buildx use $DOCKER_BUILDER
  docker buildx inspect --bootstrap
fi

deploy docker buildx build -f $PREFIX.$DOCKER_FILE -t $IMAGE_NAME \
           --build-arg ENVIRONMENT=$ENVIRONMENT \
           --build-arg ENVIRONMENT_VERSION=$ENVIRONMENT_VERSION \
           --platform $PLATFORMS \
           --push .
RESULT=$?
# Remove builder
if [ "$SHARE_BUILDERX" = "false" ]; then
  docker buildx rm $DOCKER_BUILDER
fi
if [ $RESULT -ne 0 ]; then
   exit 1
fi
echo " ===== Done! ====="