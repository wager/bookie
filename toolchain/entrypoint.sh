#!/bin/bash
set -euo pipefail

if [ "${SPARK_MODE:-}" = "master" ]; then
    # Launch a Spark master.
    exec env SPARK_NO_DAEMONIZE=true /opt/spark/sbin/start-master.sh
elif [ "${SPARK_MODE:-}" = "worker" ]; then
    # Launch a Spark worker.
    exec env SPARK_NO_DAEMONIZE=true /opt/spark/sbin/start-slave.sh "${SPARK_MASTER_URL}"
else
    # Launch a Bash shell.
    exec /bin/bash
fi
