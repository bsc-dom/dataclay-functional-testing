#!/bin/bash
NETWORK_NAME=$1
CURRENT_CONTAINER_ID=$(docker inspect $(hostname) -f "{{.Id}}")
docker network connect $NETWORK_NAME $CURRENT_CONTAINER_ID