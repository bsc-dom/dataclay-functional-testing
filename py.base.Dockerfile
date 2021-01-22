ARG ENVIRONMENT
FROM bscdataclay/dspython:develop.${ENVIRONMENT}-requirements

ENV WORKING_DIR=/testing
WORKDIR ${WORKING_DIR}
# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated jq \
        && rm -rf /var/lib/apt/lists/*
COPY ./get-docker.sh /get-docker.sh
RUN sh /get-docker.sh
RUN pip3 install behave allure-behave

RUN python3 -c "from grpc._cython import cygrpc as _cygrpc"