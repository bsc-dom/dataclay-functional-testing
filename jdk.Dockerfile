ARG ENVIRONMENT
FROM bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base

# Copy files
COPY ./pom.xml /testing/pom.xml
RUN mvn -B -DskipTests=true dependency:resolve dependency:resolve-plugins && \
    mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
COPY ./src /testing/src
RUN mvn -o package -DskipTests=true -Dmaven.javadoc.skip=true -B -V

# Get dataClay
ENV DATACLAY_JAR=/dataclay.jar
COPY --from=bscdataclay/dsjava:develop-slim /home/dataclayusr/dataclay/dataclay.jar ${DATACLAY_JAR}

COPY ./allure /testing/allure
COPY ./run_test.sh /testing/run_test.sh


# Entrypoint
ENTRYPOINT ["/testing/run_test.sh"]
