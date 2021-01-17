#!/bin/bash
#=============================================================================
source ./BUILD_MATRIX.txt
docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
DOCKER_BUILDER=$(docker buildx create)
docker buildx use $DOCKER_BUILDER
docker buildx inspect --bootstrap
printf -v PLATFORMS '%s,' "${ARCHS[@]}"
for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
  ./deploy.sh bscdataclay/continuous-integration:testing-$ENVIRONMENT-base base.Dockerfile $ENVIRONMENT "${PLATFORMS%,}" true
done

# Remove builder
docker buildx rm $DOCKER_BUILDER
echo " ===== Done! ====="



