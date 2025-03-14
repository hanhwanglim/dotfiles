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

# Editor configuration
export EDITOR='nvim'

# Path configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export PATH="$BUN_INSTALL/bin:$PATH"

# Tool installation
[ -s "/home/han/.bun/_bun" ] && source "/home/han/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"

# Tool initialization
eval "$(starship init zsh)"
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

# Aliases - Modern alternatives
if command -v nvim &> /dev/null; then
	alias vim="nvim"
	alias vi="nvim"
fi

if command -v exa &> /dev/null; then
	alias ls="exa -la --icons"
	alias ll="exa -l --icons"
	alias lt="exa -T --icons"
fi

if command -v bat &> /dev/null; then 
	alias cat="bat"
fi

if command -v z &> /dev/null; then 
	alias cd="z"
fi

alias activate="source .venv/bin/activate"
