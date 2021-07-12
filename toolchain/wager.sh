#!/bin/bash
set -euo pipefail

# Run commands with sudo when not running as root.
sudo() {
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    eval "$@"
}

# Install Bazel.
sudo npm list -g @bazel/bazelisk > /dev/null 2>&1 || sudo npm install -g @bazel/bazelisk

# # Install Wager.
if [ ! -d ~/wager ]; then
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
    git clone git@github.com:wager/wager.git ~/wager
    (cd ~/wager && bazel build //wager/analyze)
fi

# shellcheck source=/dev/null
if [ ! -f ~/.bashrc ] || ! (source ~/.bashrc && type -t wager > /dev/null 2>&1); then
    cat >> ~/.bashrc << \EOF
wager() {
    local -r root="${HOME}/wager"
    local -r workspace="wager/$1"
    local -r arguments="${@:2}"

    if [[ ! -d "${root}/${workspace}" ]]; then
        echo -e "\e[0;31m${root}/${workspace} does not exist.\e[0m"
        return 1
    elif ! grep -q 'wager_workspace' "${root}/${workspace}/BUILD"; then
        echo -e "\e[0;31m${root}/${workspace} is not a Wager workspace.\e[0m"
        return 1
    elif [[ ! -f "${root}/bazel-bin/${workspace}/app" ]] && ! (cd "${root}" && bazel build "//${workspace}:app"); then
        echo -e "\e[0;31mBuild failed. Run cd ${root} && bazel build //${workspace}:app for details.\e[0m"
        return 1
    else
        (cd "${root}/${workspace}" && eval "${root}/bazel-bin/${workspace}/app" "${arguments}")
        return $?
    fi
}

_complete_wager() {
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(cd ~/wager/wager && find * -name 'BUILD' -exec grep -q 'wager_workspace' {} ';' -printf '%h ' | sort -u))
    elif [[ ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=($(compgen -W 'backfill compute describe lab list notebook shell' -- ${COMP_WORDS[COMP_CWORD]}))
    else
        COMPREPLY=()
    fi
}

complete -F _complete_wager wager
EOF
fi
