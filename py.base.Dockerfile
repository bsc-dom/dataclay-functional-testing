ARG ENVIRONMENT
FROM bscdataclay/dspython:develop.${ENVIRONMENT}-requirements

ENV WORKING_DIR=/testing
WORKDIR ${WORKING_DIR}

COPY ./get-docker.sh /get-docker.sh
RUN sh /get-docker.sh
RUN pip3 install behave allure-behave

RUN python3 -c "from grpc._cython import cygrpc as _cygrpc"