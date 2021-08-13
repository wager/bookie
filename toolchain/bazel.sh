#!/bin/bash
set -euo pipefail

# Install Bazelisk.
sudo curl -fsSLo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64
sudo chmod +x /usr/local/bin/bazel

# Install Buildifier.
sudo curl -fsSLo /usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/download/4.0.1/buildifier-linux-amd64
sudo chmod +x /usr/local/bin/buildifier
