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

# Register a shortcut for running scripts in a Wager workspace.
wager() {
    local -r root="/workspaces/wager"
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

####################################################################################################
#                                           Completions                                            #
####################################################################################################

# Enable completions.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Register completions for the wager command.
_complete_wager() {
    if [[ "${COMP_CWORD}" -eq 1 ]]; then
        local -r workspaces="$(
            cd /workspaces/wager/wager \
            && find * -name 'BUILD' -exec grep -q 'wager_workspace' {} ';' -printf '%h\n' | sort -u
        )"
        
        mapfile -t COMPREPLY < <(compgen -W "${workspaces}" -- "${COMP_WORDS[COMP_CWORD]}")
    elif [[ "${COMP_CWORD}" -eq 2 ]]; then
        local -r scripts='backfill compute describe lab list notebook shell'
        mapfile -t COMPREPLY < <(compgen -W "${scripts}" -- "${COMP_WORDS[COMP_CWORD]}")
    else
        COMPREPLY=()
    fi
}

complete -F _complete_wager wager

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

PS1='$(prompt_user) $(prompt_path)$(prompt_branch)\$ '

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
