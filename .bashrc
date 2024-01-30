# .bashrc

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

export PATH=$PATH:/Users/bir/bin

alias k=kubectl
