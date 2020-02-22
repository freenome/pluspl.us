FROM gcr.io/freenome-build/devtools:20200218.1@sha256:a86a7665be0bb6889c906fa7037c1c75bd85a4e172d56d3be7573b8fefb53cf3 AS builder_

RUN mkdir -p /install/bin /install/lib
ENV PYTHONUSERBASE /install

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev=11.7-0+deb10u1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --user --no-cache-dir \
        --ignore-installed \
        --no-warn-script-location \
        -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt \
    && find /install/lib -type d -name __pycache__ -exec rm -rf '{}' +


FROM gcr.io/freenome-build/pybase:20200218.1@sha256:4613c12877839823bff176d6c3234a4575017fe96db02b2637116e4e0066b462

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq5=11.7-0+deb10u1 \
    && rm -rf /var/lib/apt/lists/*

# Install python requirements
COPY --from=builder_ /install/bin/ /fn/bin/
COPY --from=builder_ /install/lib/ /fn/lib/

# Copy and install package
ENV SOURCE_DIR /usr/src/app
COPY . $SOURCE_DIR

WORKDIR $SOURCE_DIR
CMD ["gunicorn", "--bind=0.0.0.0", "wsgi:application"]
