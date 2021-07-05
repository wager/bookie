#!/bin/bash
set -euo pipefail

# Run commands with sudo when not running as root.
sudo() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    eval "$@"
}

if [ -z "${SPARK_MODE+}" ]; then
    # Launch an interactive shell by default.
    exec bin/bash
elif [ "${SPARK_MODE}" == "master" ]; then
    # Laumch a Spark master.
    exec sudo start-master.sh
elif [ "${SPARK_MODE}" == "worker" ]; then
    # Launch a Spark worker.
    exec sudo start-slave.sh "${SPARK_MASTER_URL}"
else
    # Fail if unknown.
    echo "\${SPARK_MODE} is not a supported \${SPARK_MODE}"
    exit 1
fi
