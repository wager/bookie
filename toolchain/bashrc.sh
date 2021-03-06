#!/bin/bash

# Skip if not interactive.
case $- in
    *i*) ;;
      *) return;;
esac

####################################################################################################
#                                             Commands                                             #
####################################################################################################

# Enable recursive globbing. (**)
shopt -s globstar

# Enable completions.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # shellcheck source=/dev/null
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # shellcheck source=/dev/null
        . /etc/bash_completion
    fi
fi

# Register a shortcut for running scripts in a Wager workspace.
wager() {
    local -r root="${WAGER_REPOSITORY:-/workspaces/wager}"
    local -r workspace="wager/$1"

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
        (cd "${root}/${workspace}" && eval "${root}/bazel-bin/${workspace}/app" "${@:2}")
        return $?
    fi
}

_wager() {
    if [[ "${COMP_CWORD}" -eq 1 ]]; then
        local -r completions="$(
            cd "${WAGER_REPOSITORY:-/workspaces/wager}/wager" \
            && find -- * -name 'BUILD' -exec sh -c 'grep -q "wager_workspace" $1' shell {} ';' -printf '%h\n' \
            | sort -u
        )"
    elif [[ "${COMP_CWORD}" -eq 2 ]]; then
        local -r completions='backfill compute describe lab list notebook shell'
    fi

   mapfile -t COMPREPLY < <(compgen -W "${completions:-}" -- "${COMP_WORDS[COMP_CWORD]}")
}

complete -F _wager wager

####################################################################################################
#                                             Display                                              #
####################################################################################################

# Enable automatic recalculation of window dimensions.
shopt -s checkwinsize

# Colorize command output.
eval "$(dircolors -b)"
alias dir='dir --color=auto'
alias ls='ls -alh --color=auto'
alias grep='grep --color=auto'

# Enrich the command prompt.
prompt() {
    local -r user="$(whoami)@$(curl -s https://ipinfo.io/ip)"
    local -r path="$(dirs +0)"
    PS1="\[\e[0;37m\]${user}\[\e[0m\] \[\e[0;35m\]${path}\[\e[0m\]"

    if git rev-parse --is-inside-work-tree &> /dev/null 2>&1; then
        local -r branch="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')"
        if [[ -z "$(git status --porcelain)" ]]; then
            PS1+="\[\e[0;32m\]${branch}\[\e[0m\]"
        else
            PS1+="\[\e[0;31m\]${branch}\[\e[0m\]"
        fi
    fi

    PS1+="$ "
}

prompt

####################################################################################################
#                                             History                                              #
####################################################################################################

# Make the history file append-only.
shopt -s histappend

# Ignore duplicate lines and lines starting with space in the history.
HISTCONTROL=ignoreboth

# Set the size of the history and the history file.
HISTSIZE=1000
HISTFILESIZE=2000
