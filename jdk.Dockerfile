ARG ENVIRONMENT
FROM dom-ci.bsc.es/bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base
# Get jars from local to avoid copying it from different architectures
COPY ./dataclay.jar /dataclay.jar
COPY ./testing-target /testing/target
COPY ./allure /testing/allure
COPY ./entrypoint.sh /testing/entrypoint.sh

# Entrypoint
ENTRYPOINT ["/testing/entrypoint.sh"]
