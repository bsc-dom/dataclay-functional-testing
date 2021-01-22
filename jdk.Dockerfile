ARG ENVIRONMENT
ARG REGISTRY=""
FROM ${REGISTRY}bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base
# Get jars
COPY ./dataclay.jar /dataclay.jar
COPY ./testing-target /testing/target
COPY ./allure /testing/allure
COPY ./run_test.sh /testing/run_test.sh

# Entrypoint
ENTRYPOINT ["/testing/run_test.sh"]
