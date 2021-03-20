#!/bin/bash
set -euo pipefail

# Run commands with sudo when not running as root.
sudo() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    eval "$@"
}

# Install Spark.
curl -sO https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz
tar xvf spark-3.0.2-bin-hadoop3.2.tgz
sudo mv spark-3.0.2-bin-hadoop3.2 /opt/spark
rm spark-3.0.2-bin-hadoop3.2.tgz

echo "export SPARK_HOME=/opt/spark" >> ~/.profile
echo "export PATH=\${PATH}:/opt/spark/bin,mk:/opt/spark/sbin" >> ~/.profile

# Install Spark for Amazon Web Services.
curl -sO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.969/aws-java-sdk-bundle-1.11.969.jar
sudo mv aws-java-sdk-bundle-1.11.969.jar /opt/spark/jars/
curl -sO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.2/hadoop-aws-3.2.2.jar
sudo mv hadoop-aws-3.2.2.jar /opt/spark/jars/

# Install Spark for Google Cloud.
curl -sO https://github.com/GoogleCloudDataproc/spark-bigquery-connector/releases/download/0.19.1/spark-bigquery-with-dependencies_2.12-0.19.1.jar
sudo mv spark-bigquery-with-dependencies_2.12-0.19.1.jar /opt/spark/jars/
curl -sO https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar
sudo mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/
