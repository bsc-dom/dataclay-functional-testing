#!/bin/bash
if [ "$#" -ne 4 ]; then
    echo "ERROR: missing parameter. Usage ./deploy.sh IMAGE_NAME DOCKER_FILE ENVIRONMENT ARCH where:"
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
docker build -f $PREFIX.$DOCKER_FILE -t $IMAGE_NAME \
           --build-arg ENVIRONMENT=$ENVIRONMENT \
           --build-arg ENVIRONMENT_VERSION=$ENVIRONMENT_VERSION \
           .

