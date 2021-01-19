#!/bin/bash
echo "==> Cleaning scenario"
for i in "$(docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' dataclay-testing-network)"
do
  IMAGE_NAME=$(docker inspect -f "{{.Config.Image}}" $i)
  echo "      => Found active $IMAGE_NAME"
  if [[ $IMAGE_NAME == *"bscdataclay"* ]]; then
    if [[ $IMAGE_NAME != *"continuous-integration"* ]]; then
      echo "        => Removing $IMAGE_NAME"
      docker rm -f $i
    fi
  fi
done