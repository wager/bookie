#!/bin/bash
set -euo pipefail

pip3 install pre-commit
sudo pre-commit init-templatedir /usr/share/git-core/templates
