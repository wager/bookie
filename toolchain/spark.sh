#!/bin/bash
set -euo pipefail

# Run commands with sudo when not running as root.
sudo() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    eval "$@"
}

# Install Spark.
curl -fSO https://downloads.apache.org/spark/spark-3.0.3/spark-3.0.3-bin-hadoop3.2.tgz
tar xf spark-3.0.3-bin-hadoop3.2.tgz
sudo rm -rf /opt/spark || true
sudo mv spark-3.0.3-bin-hadoop3.2 /opt/spark
rm spark-3.0.3-bin-hadoop3.2.tgz

spark_home="export SPARK_HOME=/opt/spark"
grep -qxF "${spark_home}" ~/.profile || echo "${spark_home}" >> ~/.profile
spark_path="export PATH=\${PATH}:/opt/spark/bin,mk:/opt/spark/sbin"
grep -qxF "${spark_path}" ~/.profile || echo "${spark_path}" >> ~/.profile

# Install Spark dependencies.
spark_deps() {
    local -r repository='https://repo1.maven.org/maven2'
    local coordinate group artifact version

    for coordinate in "$@"; do
        IFS=: read -r group artifact version <<< "${coordinate}"
        curl -fSO "${repository}/${group//.//}/${artifact}/${version}/${artifact}-${version}.jar"
        sudo mv "${artifact}-${version}.jar" /opt/spark/jars
    done
}

spark_deps \
    com.amazon.deequ:deequ:1.2.2-spark-3.0 \
    com.amazonaws:aws-java-sdk-bundle:1.12.7 \
    com.google.cloud.bigdataoss:gcs-connector:hadoop3-2.2.1 \
    com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.21.0 \
    com.microsoft.sqlserver:mssql-jdbc:9.2.1.jre11 \
    mysql:mysql-connector-java:8.0.25 \
    net.snowflake:snowflake-jdbc:3.13.4 \
    net.snowflake:spark-snowflake_2.12:2.9.0-spark_3.0 \
    org.apache.hadoop:hadoop-aws:3.3.1 \
    org.postgresql:postgresql:42.2.21
