#!/bin/bash
#=============================================================================
source ./BUILD_MATRIX.txt
printf -v PLATFORMS '%s,' "${ARCHS[@]}"
for ENVIRONMENT in ${ENVIRONMENTS[@]}; do
  ./deploy.sh bscdataclay/continuous-integration:testing-$ENVIRONMENT-base base.Dockerfile $ENVIRONMENT "${PLATFORMS%,}"
done

echo " ===== Done! ====="



