# Autoloading functions

fpath=($HOME/.zsh/functions $HOME/.zsh/plugins $HOME/.zsh/plugins/docker-completion $fpath)

# Completion

autoload -Uz compinit; compinit
_comp_options+=(globdots)

unsetopt menu_complete   # do not autoselect the first completion entry
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word  # If unset, the cursor is set to the end of the word if completion is started. Otherwise it stays there and completion is done from both ends.
setopt always_to_end     # If a completion is performed with the cursor within a word, and a full completion is inserted, the cursor is moved to the end of the word. That is, the cursor is moved to the end of the word if either a single match is inserted or menu completion is performed.

## Allow you to select in a menu
zstyle ':completion:*:*:*:*:*' menu select

## Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

## Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

zstyle '*' single-ignored show

# https://superuser.com/questions/410356/how-do-you-make-zsh-meta-delete-behave-like-bash-to-make-it-delete-a-word-inst
autoload -U select-word-style
select-word-style bash

# [Shift-Tab] - move through the completion menu backwards
bindkey '^[[Z' reverse-menu-complete


## SSH
############################################################
# Take all host sections in .ssh/config and offer them for
# completion as hosts (e.g. for ssh, rsync, scp and the like)
# Filter out wildcard host sections.
_ssh_configfile="$HOME/.ssh/config"
# if [[ -f "$_ssh_configfile" ]]; then
#   _ssh_hosts=($(
#     egrep '^Host.*' "$_ssh_configfile" |\
#     awk '{for (i=2; i<=NF; i++) print $i}' |\
#     sort |\
#     uniq |\
#     grep -v '^*' |\
#     sed -e 's/\.*\*$//'
#   ))
#   zstyle ':completion:*:hosts' hosts $_ssh_hosts
#   unset _ssh_hosts
# fi
# unset _ssh_configfile

############################################################
# Remove host key from known hosts based on a host section
# name from .ssh/config
function ssh_rmhkey {
  local ssh_configfile="$HOME/.ssh/config"
  local ssh_host="$1"
  if [[ -z "$ssh_host" ]]; then return; fi
  ssh-keygen -R $(grep -A10 "$ssh_host" "$ssh_configfile" | grep -i HostName | head -n 1 | awk '{print $2}')
}
compctl -k hosts ssh_rmhkey

############################################################
# Load SSH key into agent
function ssh_load_key() {
  local key="$1"
  if [[ -z "$key" ]]; then return; fi
  local keyfile="$HOME/.ssh/$key"
  local keysig=$(ssh-keygen -l -f "$keyfile")
  if ( ! ssh-add -l | grep -q "$keysig" ); then
    ssh-add "$keyfile"
  fi
}

############################################################
# Remove SSH key from agent
function ssh_unload_key {
  local key="$1"
  if [[ -z "$key" ]]; then return; fi
  local keyfile="$HOME/.ssh/$key"
  local keysig=$(ssh-keygen -l -f "$keyfile")
  if ( ssh-add -l | grep -q "$keysig" ); then
    ssh-add -d "$keyfile"
  fi
}

## Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# History
HISTFILE=~/.zsh_history                     # History filepath
HISTSIZE=10000                              # How many commands from your history file are loaded into the shell’s memory
SAVEHIST=10000                              # Indicates how many commands your history file can hold (you want this equal or larger than HISTSIZE)

setopt EXTENDED_HISTORY                     # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY                        # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST               # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS                     # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS                 # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS                    # Do not display a previously found event.
setopt HIST_IGNORE_SPACE                    # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS                    # Do not write a duplicate event to the history file.
setopt HIST_VERIFY                          # Do not execute immediately upon history expansion.

# Start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey '\e[A' up-line-or-beginning-search

# Start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '\e[B' down-line-or-beginning-search

# Navigation
setopt AUTO_CD                              # Go to folder path without using cd.

setopt AUTO_PUSHD                           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS                    # Do not store duplicates in the stack.
setopt PUSHD_SILENT                         # Do not print the directory stack after pushd or popd.

unsetopt CORRECT                            # Spelling correction
unsetopt EXTENDED_GLOB                      # Not use extended globbing syntax.

eval "$(zoxide init zsh)"                   # zoxide plugin

# Starship prompt
eval "$(starship init zsh)"


# zsh-autosuggestions plugin
source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Aliases

## ls
alias ls="eza --icons=always"
alias ll='ls -l'
alias la='ls -alh'

## cd/cp/mv/rm/ls
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'

fcd() {
    cd $(fd --type d --exclude .git --follow --hidden | fzf \
        --height 40% \
        --layout reverse \
        --bind 'tab:toggle-down,btab:toggle-up' \
        --preview 'eza --icons=always {} | head -200')
}

fls() {
    fd --exclude .git --follow --hidden | fzf \
        --height 40% \
        --layout reverse \
        --bind 'tab:toggle-down,btab:toggle-up' \
        --preview 'bat -n --color=always {} 2>/dev/null || eza --icons=always {} | head -200'
}


## Git
alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gpo='git push origin'
alias gtd='git tag --delete'
alias gtdr='git tag --delete origin'
alias gr='git branch -r'
alias gplo='git pull origin'
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gl='git log'
alias gr='git remote'
alias grs='git remote show'
alias glo='git log --pretty="oneline"'
alias glol='git log --graph --oneline --decorate'

## Docker
alias d="docker"
alias dl="d logs -f --tail=50"
alias dlt="d logs -f -t --tail=50"
alias dex="d exec -it"
alias dps="d ps"

FZF_DOCKER_PS_FORMAT="table {{.Names}}\t{{.Image}}"
fdl() {
    dps --format "${FZF_DOCKER_PS_FORMAT}" | fzf \
        --header-lines=1 \
        --height 40% \
        --layout reverse \
        --bind 'enter:become(docker logs -f --tail=50 {1}),tab:toggle-down,btab:toggle-up' \
        --preview 'docker logs {1} --tail=20'
}
fdex() {
    dps --format "${FZF_DOCKER_PS_FORMAT}" | fzf \
        --header-lines=1 \
        --height 40% \
        --layout reverse \
        --bind 'enter:become(docker exec -it {1} bash || docker exec -it {1} sh),tab:toggle-down,btab:toggle-up' \
        --preview 'docker logs {1} --tail=20'
}


## Docker compose
alias dc="docker compose"
alias dcl="dc logs -f --tail=50"
alias dclt="dc logs -f -t --tail=50"
alias dcex="dc exec"
alias dcd="dc down"
alias dcdv="dc down -v"
alias dcu="dc up -d"
alias dcul="dcu && dcl"
alias dcpull="dc pull"
alias dcps="dc ps"

FZF_DOCKER_COMPOSE_PS_FORMAT="table {{.Service}}\t{{.Status}}\t{{.Image}}"
fdcex() {
    dcps --format "${FZF_DOCKER_COMPOSE_PS_FORMAT}" | fzf \
        --header-lines=1 \
        --height 40% \
        --layout reverse \
        --bind 'enter:become(docker compose exec {1} bash || docker compose exec {1} sh),tab:toggle-down,btab:toggle-up' \
        --preview 'docker compose logs {1} --tail=20'
}
fdcl() {
    dcps --format "${FZF_DOCKER_COMPOSE_PS_FORMAT}" | fzf \
        --header-lines=1 \
        --height 40% \
        --layout reverse \
        --bind 'enter:become(docker compose logs -f --tail=50 {1}),tab:toggle-down,btab:toggle-up' \
        --preview 'docker compose logs {1} --tail=20'
}


## You Should Use plugin
source $HOME/.zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh


# zsh-syntax-highlighting plugin (at the end)
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Created by `pipx` on 2024-11-12 12:36:19
export PATH="$PATH:/Users/sylvain/.local/bin"

. "$HOME/.cargo/env"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

