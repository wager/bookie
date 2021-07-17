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
    postgresql=12+214ubuntu0.1 \
    postgresql-contrib=12+214ubuntu0.1 \
    python-is-python3=3.8.2-4 \
    tini=0.18.0-1
