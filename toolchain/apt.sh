#!/bin/bash
set -euo pipefail

# Run commands with sudo when not running as root.
sudo() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    eval "$@"
}

# Install system dependencies.
sudo apt-get update --yes
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-downgrades --no-install-recommends \
    curl=7.68.0-1ubuntu2.5 \
    default-jdk=2:1.11-72 \
    git=1:2.25.1-1ubuntu3.1 \
    git-man=1:2.25.1-1ubuntu3.1 \
    jq=1.6-1ubuntu0.20.04.1 \
    liblz4-1=1.9.2-2ubuntu0.20.04.1 \
    node-gyp=6.1.0-3 \
    npm=6.14.4+ds-1ubuntu2 \
    python-is-python3=3.8.2-4 \
    python3-pip=20.0.2-5ubuntu1.5
