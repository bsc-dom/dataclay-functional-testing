#!/bin/bash
function remove_containers {
  IMAGE=$1
  CONTAINERS=$(docker ps -a | grep "$IMAGE" | awk '{print $1}')
  for container in $CONTAINERS; do
    echo "==> Removing $container"
    docker rm -v -f $container
  done
}
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
echo "==> Cleaning scenario"
remove_containers "dom-ci.bsc.es/bscdataclay/logicmodule"
remove_containers "dom-ci.bsc.es/bscdataclay/dsjava"
remove_containers "dom-ci.bsc.es/bscdataclay/dspython"
remove_containers "dom-ci.bsc.es/bscdataclay/client"
remove_containers "dom-ci.bsc.es/bscdataclay/initializer"
rm -rf /testing/stubs/*
rm -rf /testing/dbfiles/*
rm -rf stubs/*
pushd $SCRIPTDIR/..
for d in $(find . -name 'docker-compose*'); do
    echo "Cleaning /tmp/dataClay/functional-testing/storage/$(dirname $d) directory"
    rm -rf /tmp/dataClay/functional-testing/storage/$(dirname $d)/*
done
popd
echo "<== Clean!"