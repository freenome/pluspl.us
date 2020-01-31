FROM gcr.io/freenome-build/devtools:20200131.3@sha256:9ae274e0a2944beff91652ff5985c84bc6ecff6fd48b9dc38d1b218907715f63 AS builder_

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


FROM gcr.io/freenome-build/pybase:20200131.3@sha256:8b483392dfb5d23e2fee89dd7fa7227ae9896bed689baad9f124a7c863f0a818

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
