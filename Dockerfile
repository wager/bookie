FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
    && apt-get update --yes \
    && apt-get install --yes --no-install-recommends \
        curl=7.68.0-1ubuntu2.4 \
        default-jdk=2:1.11-72 \
        python-is-python3=3.8.2-4 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz \
    && tar xvf spark-3.0.2-bin-hadoop3.2.tgz \
    && mv spark-3.0.2-bin-hadoop3.2 /opt/spark \
    && rm spark-3.0.2-bin-hadoop3.2.tgz \
    && curl -O https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar \
    && mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/

LABEL org.opencontainers.image.source https://github.com/wager/platform
