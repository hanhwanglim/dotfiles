# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# eval "$(starship init zsh)"

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

alias personal="cd $HOME/Dev/personal"
alias xelix="cd $HOME/Dev/xelix"
alias backend="cd $HOME/Dev/xelix/platform-api"
alias frontend="cd $HOME/Dev/xelix/platform-front-end"

# Settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# poetry
export PATH="$HOME/.local/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Atuin
eval "$(atuin init zsh)"

# dotem
eval "$("dotem-cli" hook)"

# go
export PATH=$PATH:/usr/local/go/bin

# bun completions
[ -s "/home/han/.bun/_bun" ] && source "/home/han/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
