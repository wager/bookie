FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y curl default-jdk python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz && \
    tar xvf spark-3.0.2-bin-hadoop3.2.tgz && \
    mv spark-3.0.2-bin-hadoop3.2 /opt/spark && \
    rm spark-3.0.2-bin-hadoop3.2.tgz && \
    curl -O https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar && \
    mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/

LABEL org.opencontainers.image.source https://github.com/wager/platform
