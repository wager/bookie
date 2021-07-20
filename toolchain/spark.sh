#!/bin/bash
set -euo pipefail

# Install Spark.
spark_version='3.0.3'
sed -i.bak '/^export SPARK_VERSION=/d' ~/.profile
echo "export SPARK_VERSION='${spark_version}'" >> ~/.profile

spark_binary="spark-${spark_version}-bin-hadoop3.2"
curl -fsOS "https://downloads.apache.org/spark/spark-${spark_version}/${spark_binary}.tgz"
tar xf "${spark_binary}.tgz"
rm "${spark_binary}.tgz"
sudo rm -rf /opt/spark || true
sudo mv "${spark_binary}" /opt/spark

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

        if [ "${group}:${artifact}" = "com.google.cloud.bigdataoss:gcs-connector" ]; then
            file="${artifact}-${version}-shaded.jar"
        else
            file="${artifact}-${version}.jar"
        fi

        curl -fsOS "${repository}/${group//.//}/${artifact}/${version}/${file}"
        sudo mv "${file}" /opt/spark/jars
    done
}

spark_deps \
    com.amazon.deequ:deequ:1.2.2-spark-3.0 \
    com.amazonaws:aws-java-sdk-bundle:1.12.26 \
    com.google.cloud.bigdataoss:gcs-connector:hadoop3-2.2.2 \
    com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.21.1 \
    com.microsoft.sqlserver:mssql-jdbc:9.2.1.jre11 \
    mysql:mysql-connector-java:8.0.25 \
    net.snowflake:snowflake-jdbc:3.13.5 \
    net.snowflake:spark-snowflake_2.12:2.9.0-spark_3.0 \
    org.apache.hadoop:hadoop-aws:3.3.1 \
    org.postgresql:postgresql:42.2.23
