#!/bin/bash -e
#==============================================================================
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
# ============================= main ===================================== #
if [ "$#" -lt 1 ]; then
    echo "ERROR: missing parameter. Usage $0 dataclay-packaging-path [--images imgs] [--platforms arch] [--environments jdk8,py36,...]"
    exit 1
fi
DATACLAY_PACKAGING_PATH=$1
BUILD_DATACLAY="true"
DEPLOY_ARGS="--build --deploy-base"
shift
while test $# -gt 0
do
    case "$1" in
        --skip-dataclay)
          BUILD_DATACLAY="false"
          printWarn "Skipping dataClay build"
          ;;
        --skip-base)
          DEPLOY_ARGS="$DEPLOY_ARGS $1"
          printWarn "Skipping base test images"
          ;;
        *)
        	DEPLOY_ARGS="$DEPLOY_ARGS $1"
          ;;
    esac
    shift
done

if [ "$BUILD_DATACLAY" == "true" ]; then
  printMsg "==> Building dataClay "
  pushd $DATACLAY_PACKAGING_PATH/docker
  ./build.sh
  popd
fi
./deploy.sh $DEPLOY_ARGS
# Pull all images to test
#    docker pull --platform $DEFAULT_ARCH dom-ci.bsc.es/$IMAGE_NAME
#    docker tag dom-ci.bsc.es/$IMAGE_NAME $IMAGE_NAME

printMsg " ===== Done! ====="

