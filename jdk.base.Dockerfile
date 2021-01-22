FROM ubuntu:18.04
ARG ENVIRONMENT_VERSION
ENV WORKING_DIR=/testing
WORKDIR ${WORKING_DIR}

# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated jq python3.7 openjdk-${ENVIRONMENT_VERSION}-jdk \
        && rm -rf /var/lib/apt/lists/*
COPY ./get-docker.sh /get-docker.sh
RUN sh /get-docker.sh


RUN rm -f /usr/bin/python3 && ln -s /usr/bin/python3.7 /usr/bin/python3

# Set Java home. We create a symbolic link to be arch-independant
RUN ln -s /usr/lib/jvm/java-${ENVIRONMENT_VERSION}-openjdk* /usr/lib/jvm/java-default
ENV JAVA_HOME=/usr/lib/jvm/java-default
RUN update-alternatives --install "/usr/bin/java" "java" ${JAVA_HOME}/bin/java 99999 && \
	update-alternatives --install "/usr/bin/javac" "javac" ${JAVA_HOME}/bin/javac 99999 && \
	update-alternatives --set java ${JAVA_HOME}/bin/java && \
	update-alternatives --set javac ${JAVA_HOME}/bin/javac