#!/bin/bash
source ./BUILD_MATRIX.txt
for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
  ./build.sh bscdataclay/continuous-integration:testing-$ENVIRONMENT-base base.Dockerfile $ENVIRONMENT "${PLATFORMS%,}"
done

