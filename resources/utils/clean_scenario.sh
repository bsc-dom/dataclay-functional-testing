#!/bin/bash
echo "==> Cleaning scenario"
DATACLAY_TESTING_NETWORKS=$(docker network ls | grep dataclay-testing | awk '{print $2}')
for network in $DATACLAY_TESTING_NETWORKS; do
  IMAGES_IN_NETWORK=$(docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' $network)
  for i in $IMAGES_IN_NETWORK; do
    IMAGE_NAME=$(docker inspect -f "{{.Config.Image}}" $i)
    if [[ $IMAGE_NAME == *"bscdataclay"* ]]; then
      if [[ $IMAGE_NAME != *"continuous-integration"* ]]; then
        echo "        => Removing $i container of image $IMAGE_NAME"
        docker rm -v -f $i
      fi
    fi
  done
done
rm -rf /testing/stubs/*
rm -rf /testing/dbfiles/*
rm -rf stubs/*