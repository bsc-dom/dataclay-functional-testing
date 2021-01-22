#!/bin/bash
NETWORK_NAME=$1
CURRENT_CONTAINER_ID=$(docker inspect $(hostname) -f "{{.Id}}")
CURRENT_NETWORKS=$(docker inspect $CURRENT_CONTAINER_ID -f '{{json .NetworkSettings.Networks}}' | jq -r 'keys | join(" ")')
FOUND="false"
for CURRENT_NETWORK in ${CURRENT_NETWORKS[@]}; do
  if [ "$CURRENT_NETWORK" == "$NETWORK_NAME" ]; then
    FOUND="true"
  fi
done
if [ "$FOUND" == "false" ]; then
  echo "Connecting to network: $NETWORK_NAME"
  docker network connect $NETWORK_NAME $CURRENT_CONTAINER_ID
fi