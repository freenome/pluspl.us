FROM gcr.io/freenome-build/devtools:20200203.1@sha256:6d6c7a010345bf714549e22d5a9590d9d92042e4441caa9816f2418808882ea3 AS builder_

RUN mkdir -p /install/bin /install/lib
ENV PYTHONUSERBASE /install

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev=11.5-1+deb10u1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --user --no-cache-dir \
        --ignore-installed \
        --no-warn-script-location \
        -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt \
    && find /install/lib -type d -name __pycache__ -exec rm -rf '{}' +


FROM gcr.io/freenome-build/pybase:20200203.1@sha256:2da8e8f553512ad931a3d60ad6aa56036cb62dd51132a9daaf001b0309e45151

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev=11.5-1+deb10u1 \
    && rm -rf /var/lib/apt/lists/*

# Install python requirements
COPY --from=builder_ /install/bin/ /fn/bin/
COPY --from=builder_ /install/lib/ /fn/lib/

# Copy and install package
ENV SOURCE_DIR /usr/src/app
COPY . $SOURCE_DIR

WORKDIR $SOURCE_DIR
CMD ["gunicorn", "--bind=0.0.0.0", "wsgi:application"]
