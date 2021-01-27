#!/bin/bash -e
#==============================================================================
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; yellow=$'\e[1;33m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printWarn { echo "${yellow}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
#=== FUNCTION ================================================================
# NAME: build
# DESCRIPTION: Build docker images
#=============================================================================
function build {
  IMAGE_NAME=$1
  DOCKER_FILE=$2
  ENVIRONMENT=$3
  BUILD_ARCH=$4
  PREFIX=$(sed -e 's/[0-9]*$//' <<< "$ENVIRONMENT")
  ENVIRONMENT_VERSION=$(grep -o '[0-9].*' <<< "$ENVIRONMENT")
  if [ "$PREFIX" == "jdk" ]; then
      CONTAINER_ID=$(docker create --platform $BUILD_ARCH bscdataclay/dsjava:develop-slim)
      docker cp $CONTAINER_ID:/home/dataclayusr/dataclay/dataclay.jar $PWD/dataclay.jar
      docker rm $CONTAINER_ID
  fi
  if [ "$BUILD_ARCH" = "linux/amd64" ]; then
    docker build -f $PREFIX.$DOCKER_FILE -t $IMAGE_NAME \
               --build-arg ENVIRONMENT=$ENVIRONMENT \
               --build-arg ENVIRONMENT_VERSION=$ENVIRONMENT_VERSION \
               .
  else
    # Check if already exists
    echo "Checking builder dataclay-builderx"
    RESULT=$(docker buildx ls)
    if [[ $RESULT == *"dataclay-builderx"* ]]; then
      echo "Using already existing builder dataclay-builderx"
      docker buildx use dataclay-builderx
    else
      docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
      echo "Creating builder $BUILDERX_NAME"
      docker buildx create --driver-opt network=host --name dataclay-builderx
      docker buildx use dataclay-builderx
      docker buildx inspect --bootstrap
    fi
    if [ "$PREFIX" == "py" ]; then
      docker tag bscdataclay/dspython:develop.${ENVIRONMENT}-slim localhost:5000/bscdataclay/dspython:develop.${ENVIRONMENT}-slim
      docker push localhost:5000/bscdataclay/dspython:develop.${ENVIRONMENT}-slim
    fi

    COMMAND="docker buildx build -f $PREFIX.$DOCKER_FILE -t localhost:5000/$IMAGE_NAME \
               --platform $BUILD_ARCH \
               --build-arg REGISTRY=localhost:5000/ \
               --build-arg ENVIRONMENT=$ENVIRONMENT \
               --build-arg ENVIRONMENT_VERSION=$ENVIRONMENT_VERSION \
               --push ."
    printMsg "************* Building image localhost:5000/$IMAGE_NAME (retry $n) *************"
    printMsg "$COMMAND"
    eval "$COMMAND"
    printMsg "************* localhost:5000/$IMAGE_NAME IMAGE BUILD! (in $n retries) *************"
    docker pull --platform $BUILD_ARCH localhost:5000/$IMAGE_NAME
    docker tag localhost:5000/$IMAGE_NAME $IMAGE_NAME
  fi
}


# ============================= main ===================================== #
if [ "$#" -lt 1 ]; then
    echo "ERROR: missing parameter. Usage $0 dataclay-packaging-path [--images imgs] [--arch arch] [--environments jdk8,py36,...]"
    exit 1
fi
DATACLAY_PACKAGING_PATH=$1
BUILD_BASE="true"
BUILD_DATACLAY="true"
ARCH="linux/amd64"
shift
source ./BUILD_MATRIX.txt
DEFAULT_JAVA=8
DEFAULT_PYTHON=3.7
CLIENT_JAVA=8
CLIENT_PYTHON=3.7
while test $# -gt 0
do
    case "$1" in
        --skip-dataclay)
          BUILD_DATACLAY="false"
          printMsg "Skipping dataClay build"
          ;;
        --skip-base)
          BUILD_BASE="false"
          printMsg "Skipping base test images"
          ;;
        --images)
          shift
          IFS=',' read -r -a IMAGES <<< "$1"
          printMsg "Specified images to build: "
          for IMAGE in ${IMAGES[@]}; do
            printMsg " -- $IMAGE"
            if [ "$IMAGE" == "alpine" ]; then
              CLIENT_JAVA=11
            fi
          done
          ;;
        --arch)
          shift
          ARCH=$1
          printMsg "Specified arch to build: $ARCH"
          ;;
        --environments)
          shift
          IFS=',' read -r -a ENVIRONMENTS <<< "$1"
          printMsg "Specified environments for testing images to build:"
          for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
            printMsg " -- $ENVIRONMENT"
            PREFIX=$(sed -e 's/[0-9]*$//' <<< "$ENVIRONMENT")
            ENVIRONMENT_VERSION=$(grep -o '[0-9].*' <<< "$ENVIRONMENT")
            if [ "$PREFIX" == "jdk" ]; then
              SUPPORTED_JAVA_VERSIONS="$SUPPORTED_JAVA_VERSIONS $ENVIRONMENT_VERSION"
            elif [ "$PREFIX" == "py" ]; then
              SUPPORTED_PYTHON_VERSIONS="$SUPPORTED_PYTHON_VERSIONS $ENVIRONMENT_VERSION"
            fi
          done
          ;;
        --build-base)
          shift
          BUILD_BASE="$1"
          printWarn "Specified to build base testing images = $BUILD_BASE"
          ;;
        *) echo "Bad option $1"
        	exit 1
            ;;
    esac
    shift
done

# create platform files
if [ -z $SUPPORTED_PYTHON_VERSIONS ]; then
  SUPPORTED_PYTHON_VERSIONS="3.6 3.7 3.8"
fi
if [ -z $SUPPORTED_JAVA_VERSIONS ]; then
  SUPPORTED_JAVA_VERSIONS="8 11"
fi
if [[ "$SUPPORTED_JAVA_VERSIONS" != *$DEFAULT_JAVA* ]]; then
  DEFAULT_JAVA=$(echo $SUPPORTED_JAVA_VERSIONS | cut -d' ' -f1)
  printWarn "DEFAULT_JAVA not supported in current configuration: using first supported $DEFAULT_JAVA"
fi
if [[ "$SUPPORTED_JAVA_VERSIONS" != *$CLIENT_JAVA* ]]; then
  CLIENT_JAVA=$(echo $SUPPORTED_JAVA_VERSIONS | cut -d' ' -f1)
  printWarn "CLIENT_JAVA not supported in current configuration: using first supported $CLIENT_JAVA "
fi
if [[ "$SUPPORTED_PYTHON_VERSIONS" != *$DEFAULT_PYTHON* ]]; then
  DEFAULT_PYTHON=$(echo $SUPPORTED_PYTHON_VERSIONS | cut -d' ' -f1)
  printWarn "DEFAULT_PYTHON not supported in current configuration: using first supported $DEFAULT_PYTHON"
fi
if [[ "$SUPPORTED_PYTHON_VERSIONS" != *$DEFAULT_PYTHON* ]]; then
  DEFAULT_PYTHON=$(echo $SUPPORTED_PYTHON_VERSIONS | cut -d' ' -f1)
  printWarn "DEFAULT_PYTHON not supported in current configuration: using first supported $DEFAULT_PYTHON"
fi

tmpfile=$(mktemp /tmp/functional-testing-platforms.XXXXXX)
echo "SUPPORTED_JAVA_VERSIONS=($SUPPORTED_JAVA_VERSIONS)
SUPPORTED_PYTHON_VERSIONS=($SUPPORTED_PYTHON_VERSIONS)
DEFAULT_JAVA=$DEFAULT_JAVA
DEFAULT_PYTHON=$DEFAULT_PYTHON
CLIENT_JAVA=$CLIENT_JAVA
CLIENT_PYTHON=$CLIENT_PYTHON
PLATFORMS=$ARCH" > $tmpfile

printMsg "==> Using platforms file:"
cat $tmpfile

if [ "$BUILD_DATACLAY" == "true" ]; then
  printMsg "==> Building dataClay "
  pushd $DATACLAY_PACKAGING_PATH/docker
  for IMAGE in ${IMAGES[@]}; do
      ./build.sh --dev -y --$IMAGE --plaforms-file $tmpfile --build-platform $ARCH
  done
  popd
fi

if [ "$BUILD_BASE" == "true" ]; then
  printMsg " ==> Building base test images"
  for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
    build bscdataclay/continuous-integration:testing-$ENVIRONMENT-base base.Dockerfile $ENVIRONMENT $ARCH
  done
fi


printMsg " ==> Building test images"
docker build -f packager.jdk.Dockerfile -t bscdataclay/continuous-integration:javaclay-jar .
JAVACLAY_CONTAINER=$(docker create --rm  bscdataclay/continuous-integration:javaclay-jar)
docker cp $JAVACLAY_CONTAINER:/testing/target/ ./testing-target
docker rm $JAVACLAY_CONTAINER

for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
  build bscdataclay/continuous-integration:testing-$ENVIRONMENT Dockerfile $ENVIRONMENT $ARCH
done

rm $tmpfile
rm -f $PWD/dataclay.jar
rm -rf ./testing-target
printMsg " ===== Done! ====="

