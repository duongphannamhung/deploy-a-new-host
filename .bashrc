case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

export CLICOLOR=1
export LSCOLORS=GxBxCxDxexegedabagaced

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1="\[\033[01;92m\]@ubuntu\[\033[00m\]:\[\033[01;94m\]\w\[\033[01;35m\]\$(parse_git_branch)\[\033[00m\]\$ "

export PROMPT_COMMAND='echo -ne "\033]0;@ubuntu\007"'

case $- in
    *i*) ;;
      *) return;;
esac

set -o vi

alias g=git
alias _gs='g s | fpp'
alias _ga='g a'
alias _gc='g c'
alias _gp='g p'
alias _gP='g P'
alias _grs='g rs'
alias _gcp='g cp'

alias mk=minikube