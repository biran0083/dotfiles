# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    kube-ps1
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
PS1='$(kube_ps1)'$PS1
PATH=$PATH:~/baga/includes:~/go/bin


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.2.0/bin:$PATH"

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# User specific aliases and functions for all shells
HISTSIZE=130000 HISTFILESIZE=-1
export EDITOR=vim
set -o vi
# enable edit command line in vim
bindkey -M vicmd v edit-command-line

alias python=python3
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
alias l=less
alias grep='grep --color'

mkcd() {
    mkdir -p "$1" && cd "$1"
}
# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fh - repeat history
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fdr - cd to selected parent directory
fdr() {
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      get_parent_dirs $(dirname "$1")
    fi
  }
  local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
  cd "$DIR"
}

# fman - search man pages
fman() {
  local manpage
  manpage=$(man -k . | sort | fzf --preview='echo {} | awk '\''{print($2," ",$1)}'\'' | sed "s/[\(|\)]//g" | xargs man')
  echo "$manpage" | awk '{print($2," ",$1)}' | sed 's/[\(|\)]//g' | xargs man
}

# pid symbol search
pidsymbol () {
   local pid
   pid="$1"
   cat /proc/$pid/maps | cut -c 74- | sort | uniq | sort -n | while read line; do nm /proc/$pid/root$line 2>/dev/null; done| fzf -m
}

# perf trace program
pstat () {
   sudo ls >/dev/null
   local debugfs
   debugfs=$(mount | grep debugfs | cut -d ' ' -f3)
   local tracepoints
   tracepoints=$(sudo cat "${debugfs}/tracing/available_events" | fzf -m --preview='echo {} | sed "s/\:/\//g" | xargs -IX sudo cat "'${debugfs}'/tracing/events/X/format"')
   sudo perf stat -d -d -d -a -v -e $(echo ${tracepoints} | tr -s ' ' ',')  "$@"
}

# fkill - kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# perf trace pid
ppid () {
   sudo ls >/dev/null
   local debugfs
   debugfs=$(mount | grep debugfs | cut -d ' ' -f3)
   local tracepoints
   tracepoints=$(sudo cat "${debugfs}/tracing/available_events" | fzf -m --preview='echo {} | sed "s/\:/\//g" | xargs -IX sudo cat "'${debugfs}'/tracing/events/X/format"')
   if [ -z "$2" ]; then
     sudo perf stat -a -v -e $(echo ${tracepoints} | tr -s ' ' ',') -p $1
   else
     sudo perf record -s -n --group -a -v -e $(echo ${tracepoints} | tr -s ' ' ',') -p $1 -o $2
   fi
}

# ngrep tcp port
t4port () {
   local tport
   tport=$(sudo ss -tlpn4 | sed '1d' | tr -s ' ' | fzf --preview='echo {} | cut -d ":" -f2 | cut -d " " -f1 | sudo xargs -IX ngrep -W byline -d any -q "" "tcp port X"' | cut -d ':' -f2 | cut -d ' ' -f1)
   sudo ngrep -W byline -d any -q '' "tcp port $tport"
}

# ungrep- ngrep udp sockets
ungrep () {
   local filter
   filter=$(ss -au | grep -vi state | fzf -m | tr -s ' ' | cut -d ' ' -f4 | cut -d ':' -f1)
   ngrep -W byline -d any "$filter"
}

klog() {
  kubectl logs -f $(kubectl get pods  | fzf | cut -d' ' -f1)
}

kpod() {
  kubectl get pods  | fzf | cut -d' ' -f1
}

kdesc() {
  kubectl describe pod $(kpod)
}

kbash() {
  kubectl exec -it $(kpod) -- /bin/bash
}

alias tmux='tmux -2'

gamend() {
  git add -A
  git commit --amend -C HEAD
}

gitco() {
  git branch | grep -v "^\*" | fzf --height=20% --reverse --info=inline | xargs git checkout
}

function kfwd() {
    pod=$1
    port=$2
    shift 2
    kubectl port-forward "$pod" "$port:$port" >/dev/null &
    kubectl_pid=$!
    trap "kill $kubectl_pid 2>/dev/null" EXIT
    # Wait for the port-forwarding to start listening
    while ! lsof -i :"$port"| grep kubectl  >/dev/null 2>&1; do sleep 0.1; done
    "$@"
    kill $kubectl_pid 2>/dev/null
    trap - EXIT
}

function kstack() {
  kubectl exec  $(kpod) -- /bin/bash -c " apt-get install -y rust-gdb &&  rust-gdb -p 1 -ex 'thread apply all bt'" | rustfilt
}

function gbc() {
  gb -c $1 && gco $1
}

export CPATH=/opt/homebrew/include
export LIBRARY_PATH=/opt/homebrew/lib

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export TOOLCHAINS=swift

export PATH=$PATH:/Users/bir/bin

alias k=kubectl
