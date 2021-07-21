#!/bin/bash
set -euo pipefail

if ! [ -f ~/.bashrc ] || ! grep -q '^PS1=' ~/.bashrc; then
    cat >> ~/.bashrc << \EOF
prompt_ip="$(curl -s https://ipinfo.io/ip)"

prompt_user() {
    user="$(whoami)@${prompt_ip}"
    echo -en "\e[0;37m${user}\e[0m"
}

prompt_path() {
    path="$(dirs +0)"
    echo -en "\e[0;35m${path}\e[0m"
}

prompt_branch() {
    if git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
        branch="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')"
        if [[ -z "$(git status --porcelain)" ]]; then
            echo -en "\e[0;32m${branch}\e[0m"
        else
            echo -en "\e[0;31m${branch}\e[0m"
        fi
    fi
}

PS1="\$(prompt_user) \$(prompt_path)\$(prompt_branch)$ "
EOF
fi
