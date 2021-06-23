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
    python3-pip=20.0.2-5ubuntu1.5
