# Machine-local settings, sourced by practicalli zshrc (${ZDOTDIR}/local.zsh).
# Put secrets in ~/.config/zsh/local.secrets.zsh (untracked) instead of here.
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
[[ -f "$HOME/.config/zsh/local.secrets.zsh" ]] && source "$HOME/.config/zsh/local.secrets.zsh"

source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

export PATH="$HOME/.local/bin:$HOME/scripts:$PATH"
export JAVA_HOME="$(brew --prefix openjdk)"
export PATH="$JAVA_HOME/bin:$PATH"

alias ll='ls -alh'
alias claude='claude --dangerously-skip-permissions'
alias nvim-clj='NVIM_APPNAME=nvim-clojure nvim'
