#!/bin/bash
set -euo pipefail

pip3 install pre-commit
git config --global init.templateDir /usr/share/git-core/templates
pre-commit init-templatedir /usr/share/git-core/templates
