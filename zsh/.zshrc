# Autoloading functions

fpath=($HOME/.zsh/functions $HOME/.zsh/plugins $HOME/.zsh/plugins/docker-completion $fpath)

# Completion

autoload -Uz compinit; compinit

setopt MENU_COMPLETE        # Automatically highlight first element of completion menu

## Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

## Allow you to select in a menu
zstyle ':completion:*' menu select

## SSH
source $HOME/.zsh/plugins/zsh-ssh/zsh-ssh.zsh

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

# Navigation
setopt AUTO_CD                              # Go to folder path without using cd.

setopt AUTO_PUSHD                           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS                    # Do not store duplicates in the stack.
setopt PUSHD_SILENT                         # Do not print the directory stack after pushd or popd.

unsetopt CORRECT                            # Spelling correction
unsetopt EXTENDED_GLOB                      # Not use extended globbing syntax.

source $HOME/.zsh/plugins/zsh-bd/bd.zsh     # bd plugin
eval "$(zoxide init zsh)"                   # zoxide plugin


# Starship prompt
eval "$(starship init zsh)"

# Syntax highlightinh
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions
source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Aliases

## cat/bat
source $HOME/.zsh/plugins/zsh-bat/zsh-bat.plugin.zsh

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

