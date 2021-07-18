#!/bin/bash
set -euo pipefail

# Install Bazelisk.
sudo curl -fsSLo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64
sudo chmod +x /usr/local/bin/bazel
