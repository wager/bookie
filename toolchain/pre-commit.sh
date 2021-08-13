#!/bin/bash
set -euo pipefail

pip3 install pre-commit
git config --global init.templateDir ~/.git-template
pre-commit init-templatedir ~/.git-template
