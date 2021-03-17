FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update --yes \
    && apt-get install --yes --no-install-recommends \
        curl=7.68.0-1ubuntu2.4 \
        default-jdk=2:1.11-72 \
        python-is-python3=3.8.2-4 \
        sudo=1.8.31-1ubuntu1.2 \
    && rm -rf /var/lib/apt/lists/*

RUN \
    curl -sO https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz \
    && tar xvf spark-3.0.2-bin-hadoop3.2.tgz \
    && mv spark-3.0.2-bin-hadoop3.2 /opt/spark \
    && rm spark-3.0.2-bin-hadoop3.2.tgz \
    && curl -sO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.969/aws-java-sdk-bundle-1.11.969.jar \
    && mv aws-java-sdk-bundle-1.11.969.jar /opt/spark/jars/ \
    && curl -sO https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar \
    && mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/ \
    && curl -sO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.2/hadoop-aws-3.2.2.jar \
    && mv hadoop-aws-3.2.2.jar /opt/spark/jars/ \
    && curl -sO https://github.com/GoogleCloudDataproc/spark-bigquery-connector/releases/download/0.19.1/spark-bigquery-with-dependencies_2.12-0.19.1.jar \
    && mv spark-bigquery-with-dependencies_2.12-0.19.1.jar /opt/spark/jars/

LABEL \
    org.opencontainers.image.authors="ashwin.madavan@gmail.com" \
    org.opencontainers.image.description="A Spark installation on Ubuntu 20.04 LTS." \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/wager/bookie" \
    org.opencontainers.image.title="Wager Runtime" \
    org.opencontainers.image.vendor="wager"
