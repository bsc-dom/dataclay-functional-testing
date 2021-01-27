#!/bin/bash
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; yellow=$'\e[1;33m'; end=$'\e[0m';
NETWORK_NAME=$1
CURRENT_CONTAINER_ID=$(docker inspect $(hostname) -f "{{.Id}}")
echo "${yellow} Disconnecting from network: $NETWORK_NAME ${end}"
docker network disconnect $NETWORK_NAME $CURRENT_CONTAINER_ID