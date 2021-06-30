#!/bin/bash
set -euo pipefail

# Acquire a GitHub Actions registration `TOKEN` using a repo-scoped `PERSONAL_ACCESS_TOKEN`.
TOKEN="$(
    curl \
        -s \
        -X POST \
        -H "authorization: token ${PERSONAL_ACCESS_TOKEN}" \
        'https://api.github.com/repos/wager/wager/actions/runners/registration-token' \
    | jq -r '.token'
)"

# Find the latest `TAG` and `RUNNER` for GitHub Actions.
TAG=$(curl -s 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')
RUNNER="actions-runner-linux-x64-${TAG:1}.tar.gz"

# Download and install the `RUNNER`.
mkdir actions-runner && cd "$_"
curl -s -o "${RUNNER}" -L "https://github.com/actions/runner/releases/download/${TAG}/${RUNNER}"
tar xzf "./${RUNNER}"

# Add the `RUNNER` and remove on exit.
./config.sh \
    --name "$(hostname)" \
    --replace \
    --token "${TOKEN}" \
    --unattended \
    --url https://github.com/wager/wager

remove() {
    ./config.sh remove --token "${TOKEN}"
    cd ..
    rm -rf actions-runner
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

# Run the `RUNNER`.
./run.sh
