#!/bin/bash
if [ "$#" -lt 4 ]; then
    echo "ERROR: missing parameter. Usage  $0 TESTNAME ENVIRONMENT ARCH IMAGE"
    exit 1
fi

TESTNAME=$1
ENVIRONMENT=$2
ENVIRONMENT_VERSION=$(grep -o '[0-9].*' <<< "$ENVIRONMENT")
ARCH=$3
IMAGE=$4
SPECIFIC_OPTIONS=""
if [ "$#" -gt 4 ]; then
  all_args=("$@")
  rest_args=("${all_args[@]:4}")
  echo "-- specific options = $rest_args"
  SPECIFIC_OPTIONS="$rest_args"
fi
if  [ "$IMAGE" = "alpine" ] && [ "$ENVIRONMENT" = "jdk8" ]; then
    echo "WARNING: IMAGE alpine and ENVIRONMENT jdk8 not supported! Skipping"
    exit 0
fi
OS=$(python3 -c 'import platform; print(platform.system())')
if [ -z "${HOST_PWD}" ]; then
  HOST_PWD=$PWD
fi
LANGUAGE="None"
if [[ $ENVIRONMENT == jdk* ]]; then
  LANGUAGE="java"
elif [[ $ENVIRONMENT == py* ]]; then
  LANGUAGE="python"
fi
if [ -z $HOST_USER_ID ] || [ -z $HOST_GROUP_ID ]; then
  HOST_USER_ID=$(id -u)
  HOST_GROUP_ID=$(id -g)
fi
DEBUG_FLAG=""
if [ "$DEBUG" = "True" ]; then
  echo "!! DEBUG is active"
  DEBUG_FLAG="-Dlog4j.configurationFile=resources/common/cfgfiles/debug.xml"
fi
echo "*********** Running $TESTNAME tests using language=$LANGUAGE env=$ENVIRONMENT_VERSION image=$IMAGE arch=$ARCH ***********"
if [[ $ENVIRONMENT == jdk* ]]; then
  #   -Dlog4j.configurationFile=src/test/resources/common/cfgfiles/log4j2.xml \
  java -cp $DATACLAY_JAR:target/functional-testing-1.0.0-SNAPSHOT-jar-with-dependencies.jar:target/functional-testing-1.0.0-SNAPSHOT-tests.jar \
    -Djdk="$ENVIRONMENT_VERSION" -Dimage="$IMAGE" -Darch="$ARCH" -Dhost_pwd="$HOST_PWD" -Dtest_network="dataclay-testing-network" \
    -DuserID="$HOST_USER_ID" -DgroupID="$HOST_GROUP_ID" $DEBUG_FLAG \
    $SPECIFIC_OPTIONS -Dcucumber.options="features/$TESTNAME" \
    org.junit.runner.JUnitCore steps.RunCucumberTest
  EXIT_CODE=$?
elif [[ $ENVIRONMENT == py* ]]; then
  python3 -u -m behave -D pyver="$ENVIRONMENT_VERSION" -D image="$IMAGE" -D arch="$ARCH" -D host_pwd="$HOST_PWD" -D test_network="dataclay-testing-network"\
          -D userID="$HOST_USER_ID" -D groupID="$HOST_GROUP_ID" \
          --no-capture-stderr --no-capture --no-logcapture \
          -f allure_behave.formatter:AllureFormatter -f pretty -o ./allure-results \
          $SPECIFIC_OPTIONS --include features/${TESTNAME}
  EXIT_CODE=$?
fi

# Post process results
python3 ./allure/postprocess_results.py ./allure-results/ $LANGUAGE $ENVIRONMENT $OS $ARCH $IMAGE

if [ ! -z $HOST_USER_ID ] && [ ! -z $HOST_GROUP_ID ]; then
  chown $HOST_USER_ID:$HOST_GROUP_ID ./allure-results/ -R
fi
exit $EXIT_CODE