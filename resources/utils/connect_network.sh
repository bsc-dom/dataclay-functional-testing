#!/bin/bash
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; yellow=$'\e[1;33m'; end=$'\e[0m';

NETWORK_NAME=$1
CURRENT_CONTAINER_ID=$(docker inspect $(hostname) -f "{{.Id}}")
CURRENT_NETWORKS=$(docker inspect $CURRENT_CONTAINER_ID -f '{{json .NetworkSettings.Networks}}' | jq -r 'keys | join(" ")')
FOUND="false"
for CURRENT_NETWORK in ${CURRENT_NETWORKS[@]}; do
  if [ "$CURRENT_NETWORK" == "$NETWORK_NAME" ]; then
    FOUND="true"
  fi
  #elif [ "$CURRENT_NETWORK" != "bridge" ]; then
  #  echo "${yellow} Disconnecting from network: $CURRENT_NETWORK ${end}"
  #  docker network disconnect $CURRENT_NETWORK $CURRENT_CONTAINER_ID
  #fi
done
if [ "$FOUND" == "false" ]; then
  echo "${yellow} Connecting to network: $NETWORK_NAME ${end}"
  docker network connect $NETWORK_NAME $CURRENT_CONTAINER_ID
fi