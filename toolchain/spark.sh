#!/bin/bash
set -euo pipefail

# Run commands with sudo when not running as root.
sudo() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    eval "$@"
}

# Install Spark.
curl -sO https://downloads.apache.org/spark/spark-3.0.2/spark-3.0.2-bin-hadoop3.2.tgz
tar xf spark-3.0.2-bin-hadoop3.2.tgz
sudo mv spark-3.0.2-bin-hadoop3.2 /opt/spark
rm spark-3.0.2-bin-hadoop3.2.tgz

echo "export SPARK_HOME=/opt/spark" >> ~/.profile
echo "export PATH=\${PATH}:/opt/spark/bin,mk:/opt/spark/sbin" >> ~/.profile

# Install Spark for Big Query.
curl -sO https://github.com/GoogleCloudDataproc/spark-bigquery-connector/releases/download/0.19.1/spark-bigquery-with-dependencies_2.12-0.19.1.jar
sudo mv spark-bigquery-with-dependencies_2.12-0.19.1.jar /opt/spark/jars/

# Install Spark for Deequ.
curl -sO https://repo1.maven.org/maven2/com/amazon/deequ/deequ/1.2.2-spark-3.0/deequ-1.2.2-spark-3.0.jar
sudo mv deequ-1.2.2-spark-3.0.jar /opt/spark/jars/

# Install Spark for Google Cloud Storage.
curl -sO https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-2.2.0.jar
sudo mv gcs-connector-hadoop3-2.2.0.jar /opt/spark/jars/

# Install Spark for MySQL.
curl -sO https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-8.0.23.tar.gz
tar xf mysql-connector-java-8.0.23.tar.gz
rm mysql-connector-java-8.0.23.tar.gz
sudo mv mysql-connector-java-8.0.23/mysql-connector-java-8.0.23.jar /opt/spark/jars/
rm -rf mysql-connector-java-8.0.23

# Install Spark for PostgreSQL.
curl -sO https://jdbc.postgresql.org/download/postgresql-42.2.19.jar
sudo mv postgresql-42.2.19.jar /opt/spark/jars/

# Install Spark for S3.
curl -sO https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.969/aws-java-sdk-bundle-1.11.969.jar
sudo mv aws-java-sdk-bundle-1.11.969.jar /opt/spark/jars/
curl -sO https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.2/hadoop-aws-3.2.2.jar
sudo mv hadoop-aws-3.2.2.jar /opt/spark/jars/

# Install Spark for Snowflake.
curl -sO https://search.maven.org/classic/remotecontent?filepath=net/snowflake/spark-snowflake_2.12/2.8.4-spark_3.0/spark-snowflake_2.12-2.8.4-spark_3.0.jar
sudo mv spark-snowflake_2.12-2.8.4-spark_3.0.jar /opt/spark/jars/
curl -sO https://search.maven.org/classic/remotecontent?filepath=net/snowflake/snowflake-jdbc/3.13.1/snowflake-jdbc-3.13.1.jar
sudo mv snowflake-jdbc-3.13.1.jar /opt/spark/jars/

# Install Spark for SQL Server.
curl -sO https://download.microsoft.com/download/4/c/3/4c31fbc1-62cc-4a0b-932a-b38ca31cd410/sqljdbc_9.2.1.0_enu.tar.gz
tar xf sqljdbc_9.2.1.0_enu.tar.gz
rm sqljdbc_9.2.1.0_enu.tar.gz
sudo mv sqljdbc_9.2/enu/mssql-jdbc-9.2.1.jre11.jar /opt/spark/jars/
rm -rf sqljdbc_9.2
