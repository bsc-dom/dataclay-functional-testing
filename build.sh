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
    echo "ERROR: missing parameter. Usage $0 dataclay-packaging-path [--image-types \"alpine slim ...\"] [--platforms \"linux/arm64 linux/amd64 ...\"] [--environments \"jdk8 py36 ...\"]"
    exit 1
fi
DATACLAY_PACKAGING_PATH=$1
BUILD_DATACLAY="true"
DEPLOY_ARGS="--build --deploy-base"
DEPLOY_DC_ARGS=""
SLIM_ADDED=false
shift
while test $# -gt 0
do
    case "$1" in
        --skip-dataclay)
          BUILD_DATACLAY="false"
          printWarn "Skipping dataClay build"
          ;;
        --image-types)
          shift
          if [[ ! -z $IMAGE_TYPES ]]; then
            IMAGE_TYPES="$1 $IMAGE_TYPES"
          else
            IMAGE_TYPES="$1"
          fi
          ;;
        --environments)
          shift
          IFS=' ' read -r -a ENVIRONMENTS <<< "$1"
          ENVIRONMENTS_STR=""
          for element in "${ENVIRONMENTS[@]}"; do
              ENVIRONMENTS_STR="$element $ENVIRONMENTS_STR"
              if [[ $element == py* ]]; then
                printWarn "Building slim images for pyclay testing"
                if [[ ! -z $IMAGE_TYPES ]] && [[ $SLIM_ADDED != "true" ]]; then
                  IMAGE_TYPES="slim $IMAGE_TYPES"
                else
                  IMAGE_TYPES="slim"
                fi
                SLIM_ADDED=true
              fi
          done
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
  if [[ ! -z $IMAGE_TYPES ]]; then
    ./build.sh $DEPLOY_DC_ARGS --image-types "$IMAGE_TYPES"
  else
    ./build.sh $DEPLOY_DC_ARGS
  fi
  popd
fi

if [[ ! -z $IMAGE_TYPES ]] && [[ ! -z $ENVIRONMENTS_STR ]]; then
  echo ./deploy.sh $DEPLOY_ARGS --image-types "$IMAGE_TYPES" --environments "$ENVIRONMENTS_STR"
  ./deploy.sh $DEPLOY_ARGS --image-types "$IMAGE_TYPES" --environments "$ENVIRONMENTS_STR"
elif [[ ! -z $IMAGE_TYPES ]] && [[ -z $ENVIRONMENTS_STR ]]; then
  echo ./deploy.sh $DEPLOY_ARGS --image-types "$IMAGE_TYPES"
  ./deploy.sh $DEPLOY_ARGS --image-types "$IMAGE_TYPES"
elif [[ -z $IMAGE_TYPES ]] && [[ ! -z $ENVIRONMENTS_STR ]]; then
  echo ./deploy.sh $DEPLOY_ARGS --environments "$ENVIRONMENTS_STR"
  ./deploy.sh $DEPLOY_ARGS --environments "$ENVIRONMENTS_STR"
else
  echo ./deploy.sh $DEPLOY_ARGS
  ./deploy.sh $DEPLOY_ARGS
fi

# Pull all images to test
#    docker pull --platform $DEFAULT_ARCH dom-ci.bsc.es/$IMAGE_NAME
#    docker tag dom-ci.bsc.es/$IMAGE_NAME $IMAGE_NAME

printMsg " ===== Done! ====="

