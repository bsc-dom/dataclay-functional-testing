ARG ENVIRONMENT
FROM bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base

# Get jars
ENV DATACLAY_JAR=/dataclay.jar
COPY --from=bscdataclay/dsjava:develop-slim /home/dataclayusr/dataclay/dataclay.jar ${DATACLAY_JAR}
COPY ./testing-target /testing/target
COPY ./allure /testing/allure
COPY ./run_test.sh /testing/run_test.sh

# Entrypoint
ENTRYPOINT ["/testing/run_test.sh"]
