ARG ENVIRONMENT
ARG IMAGE_DC
FROM dom-ci.bsc.es/bscdataclay/dsjava:develop.${ENVIRONMENT}${IMAGE_DC}
FROM dom-ci.bsc.es/bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base
# Get jars from local to avoid copying it from different architectures
COPY --from=0 /home/dataclayusr/dataclay/dataclay.jar /dataclay.jar
COPY ./testing-target /testing/target
COPY ./allure /testing/allure
COPY ./entrypoint.sh /testing/entrypoint.sh

# Entrypoint
ENTRYPOINT ["/testing/entrypoint.sh"]
