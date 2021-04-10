ARG ENVIRONMENT
ARG IMAGE_DC
FROM dom-ci.bsc.es/bscdataclay/dspython:develop.${ENVIRONMENT}-slim as pyclay-venv
FROM dom-ci.bsc.es/bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base
# Get pyClay
ENV DATACLAY_VIRTUAL_ENV=/home/dataclayusr/dataclay/dataclay_venv
COPY --from=pyclay-venv /home/dataclayusr/dataclay/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
RUN python3 -c "import dataclay; print('import ok')"

# Copy files
COPY ./allure /testing/allure
COPY ./entrypoint.sh /testing/entrypoint.sh

# Entrypoint
ENTRYPOINT ["/testing/entrypoint.sh"]
