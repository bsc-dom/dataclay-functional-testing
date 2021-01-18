#!/bin/bash
echo "==> Building testing images for current system architecture only"
echo "==> Building dataClay first"
if [ "$#" -ne 1 ]; then
    echo "ERROR: missing parameter. Usage $0 dataclay-packaging-path"
    exit 1
fi
DATACLAY_PACKAGING_PATH=$1
pushd $DATACLAY_PACKAGING_PATH/docker
  ./build_all_dev.sh
popd
echo " ==> Building test images"
source ./BUILD_MATRIX.txt

docker build -f packager.jdk.Dockerfile -t bscdataclay/continuous-integration:javaclay-jar .
JAVACLAY_CONTAINER=$(docker create --rm  bscdataclay/continuous-integration:javaclay-jar)
docker cp $JAVACLAY_CONTAINER:/testing/target/ ./testing-target
docker rm $JAVACLAY_CONTAINER

for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
  ./build.sh bscdataclay/continuous-integration:testing-$ENVIRONMENT Dockerfile $ENVIRONMENT "${PLATFORMS%,}"
done

rm -rf ./testing-target
echo " ===== Done! ====="
