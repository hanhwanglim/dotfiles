HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="yyyy-mm-dd"

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS # ignore duplication command history list
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY # share command history data


# Antigen
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

fpath=(${ZDOTDIR:-~}/.antidote/functions $fpath)
autoload -Uz antidote

if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

source ${zsh_plugins}.zsh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

alias vim="nvim"
alias ea="exa -la --icons"
alias cat="bat"


eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

[ -s "/home/han/.bun/_bun" ] && source "/home/han/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"

export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export PATH="$BUN_INSTALL/bin:$PATH"
