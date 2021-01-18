FROM maven:3.6.1-jdk-8-alpine
ENV WORKING_DIR=/testing
WORKDIR ${WORKING_DIR}
COPY ./pom.xml /testing/pom.xml
RUN mvn -B -DskipTests=true dependency:resolve dependency:resolve-plugins && \
    mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
COPY ./src /testing/src
RUN mvn -o package -DskipTests=true -Dmaven.javadoc.skip=true -B -V
