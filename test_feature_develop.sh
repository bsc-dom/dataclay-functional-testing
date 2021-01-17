#!/bin/bash
echo " ** WARNING: THIS SCRIPT IS ONLY FOR DEBUGGING OR DEVELOPMENT OF TESTS SINCE
IT IS NOT USING DOCKERIZED ENVIRONMENT WITH EVERYTHING INSTALLED FOR RUNNING TESTS **"
if [ "$#" -lt 4 ]; then
    echo "ERROR: missing parameter. Usage $0 PACKAGING-PATH TEST ENVIRONMENT IMAGE BUILD where:"
    echo "    PACKAGING-PATH: path to dataclay-packaging repository with submodules initialized"
    echo "    ENVIRONMENT: (jdk8, jdk11, py36, py37, py38)"
    echo "    BUILD: (true, false)"
    exit 1
fi
DATACLAY_PACKAGING_PATH=$1
TEST=$2
ENVIRONMENT=$3
ARCH=linux/amd64
IMAGE=$4
BUILD=true
if [ "$#" -gt 4 ]; then
  BUILD=$5
fi
source ./BUILD_MATRIX.txt

if [ "$BUILD" = "true" ]; then
  echo " ==> Building dataClay "
  pushd $DATACLAY_PACKAGING_PATH/docker
    ./build_all_dev.sh
  popd

  if [[ $ENVIRONMENT == py* ]]; then
    echo " ==> Activating virtualenv and installing pyClay "
    source ./venv/bin/activate
    pushd $DATACLAY_PACKAGING_PATH/docker/dspython/pyclay
    python3 setup.py install
  elif [[ $ENVIRONMENT == jdk* ]]; then
    echo " ==> Installing javaclay in local m2 repositories "
    pushd $DATACLAY_PACKAGING_PATH/docker/logicmodule/javaclay
    mvn package -DskipTests=true
    VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | sed -n -e '/^\[.*\]/ !{ /^[0-9]/ { p; q } }')
    export DATACLAY_JAR=$DATACLAY_PACKAGING_PATH/docker/logicmodule/javaclay/target/dataclay-$VERSION-jar-with-dependencies.jar
    popd
    echo " ==> Compile tests "
    mvn package -DskipTests=true
  fi
fi

### RUN TEST
export TEST_TYPE="local"
docker network create dataclay-testing-network
EXIT_CODE=0
rm -rf $PWD/stubs
./run_test.sh $TEST $ENVIRONMENT $ARCH $IMAGE
RESULT=$?
if [ $RESULT -ne 0 ]; then
  EXIT_CODE=$RESULT
fi
rm -rf $PWD/stubs
docker network rm dataclay-testing-network 2>/dev/null

if [ "$BUILD" = "true" ]; then
  if [[ $ENVIRONMENT == py* ]]; then
    deactivate
  fi
fi
exit $EXIT_CODE