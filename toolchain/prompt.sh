#!/bin/bash
set -euo pipefail

cat >> ~/.bashrc << \EOF
prompt_user() {
    me=$(whoami)
    ip=$(curl -s https://ipinfo.io/ip)
    echo -en "\e[0;37m$me@$ip\e[0m"
}

prompt_path() {
    path=$(dirs +0)
    echo -en "\e[0;35m$path\e[0m"
}

prompt_branch() {
    if git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
        branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')
        if [ -z "$(git status --porcelain)" ]; then
            echo -en "\e[0;32m$branch\e[0m"
        else
            echo -en "\e[0;31m$branch\e[0m"
        fi
    fi
}

PS1="\$(prompt_user) \$(prompt_path)\$(prompt_branch)$ "
EOF
