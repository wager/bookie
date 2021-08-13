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
    build-essential=12.8ubuntu1.1 \
    curl=7.68.0-1ubuntu2.6 \
    default-jdk=2:1.11-72 \
    git=1:2.25.1-1ubuntu3.1 \
    jq=1.6-1ubuntu0.20.04.1 \
    python-is-python3=3.8.2-4 \
    python3-distutils=3.8.10-0ubuntu1~20.04 \
    python3-pip=20.0.2-5ubuntu1.5 \
    python3-lxml=4.5.0-1ubuntu0.3 \
    sudo=1.8.31-1ubuntu1.2 \
    tini=0.18.0-1

# Install Node.js dependencies.
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes nodejs=16.6.2-deb-1nodesource1
