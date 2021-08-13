#!/bin/bash
set -euo pipefail

pip3 install pre-commit
pre-commit init-templatedir /usr/share/git-core/templates
