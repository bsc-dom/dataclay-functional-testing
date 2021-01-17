ARG ENVIRONMENT
FROM bscdataclay/dspython:develop.${ENVIRONMENT}-slim as pyclay-venv
FROM bscdataclay/continuous-integration:testing-${ENVIRONMENT}-base

# Get pyClay
ENV DATACLAY_VIRTUAL_ENV=/dataclay_venv
COPY --from=pyclay-venv /home/dataclayusr/dataclay/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
RUN python3 -c "import dataclay; print('import ok')"

# Copy files
COPY ./allure /testing/allure
COPY ./run_test.sh /testing/run_test.sh

# Entrypoint
ENTRYPOINT ["/testing/run_test.sh"]
