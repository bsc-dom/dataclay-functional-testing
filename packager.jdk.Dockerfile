FROM maven:3.6.1-jdk-8-alpine
WORKDIR /testing/
COPY ./pom.xml /testing/pom.xml
RUN mvn -B -DskipTests=true de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
COPY ./dataclay.jar /dataclay.jar
RUN mvn install:install-file -Dfile=/dataclay.jar -DgroupId=es.bsc.dataclay \
    -DartifactId=dataclay -Dversion=2.6.1-SNAPSHOT -Dpackaging=jar -DgeneratePom=true
COPY ./src /testing/src
RUN mvn -o package -DskipTests=true -Dmaven.javadoc.skip=true -B -V
