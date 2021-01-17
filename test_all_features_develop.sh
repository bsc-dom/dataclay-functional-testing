#!/bin/bash
echo " ==> Building dataClay "
if [ "$#" -ne 2 ]; then
    echo "ERROR: missing parameter. Usage $0 PACKAGING-PATH ENVIRONMENT where:"
    echo "    PACKAGING-PATH: path to dataclay-packaging repository with submodules initialized"
    echo "    ENVIRONMENT: (jdk8, jdk11, py36, py37, py38)"
    exit 1
fi
DATACLAY_PACKAGING_PATH=$1
ENVIRONMENT=$2
pushd $DATACLAY_PACKAGING_PATH/docker
  ./build_all_dev.sh
popd
source ./BUILD_MATRIX.txt
echo " ==> Cleaning previous results of tests "
rm -rf ./allure-results
mkdir -p ./allure-results

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

echo " ==> Running tests "
TESTS=()
pushd ./features/
for f in *.feature; do
    FEATURE="${f%.feature}"
    printf '%s\n' "${FEATURE}"
    TESTS+=(${FEATURE})
done
popd

EXIT_CODE=0
for TEST in ${TESTS[@]}; do
    for IMAGE in ${IMAGES[@]}; do
        ./test_feature_develop.sh $DATACLAY_PACKAGING_PATH $TEST $ENVIRONMENT $IMAGE false
        RESULT=$?
        if [ $RESULT -ne 0 ]; then
            EXIT_CODE=$RESULT
        fi
     done
done



if [[ $ENVIRONMENT == py* ]]; then
  deactivate
fi
exit $EXIT_CODE