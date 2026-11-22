#!/usr/bin/env bash
# Bootstrap a fresh macOS machine. Idempotent: safe to re-run.
#   git clone https://github.com/mixify/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# 1. Homebrew + packages
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
brew bundle --file="$DOTFILES/Brewfile"

# 2. Symlinks (existing real files are moved to ~/.dotfiles-backup/)
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    [[ "$(readlink "$dst")" == "$src" ]] && return 0
    mkdir -p "$BACKUP" && mv "$dst" "$BACKUP/$(basename "$dst")"
    echo "backed up $dst -> $BACKUP"
  fi
  ln -s "$src" "$dst" && echo "linked $dst"
}
link .zshrc               "$HOME/.zshrc"
link .vimrc               "$HOME/.vimrc"
link .config/kitty        "$HOME/.config/kitty"
link .config/nvim         "$HOME/.config/nvim"          # SuperCollider
link .config/nvim-clojure "$HOME/.config/nvim-clojure"  # NVIM_APPNAME=nvim-clojure nvim
link clojure              "$HOME/clojure"

# 3. iTerm2: load settings from this repo
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# 4. Neovim plugins + parsers
nvim --headless "+Lazy! sync" +qa
NVIM_APPNAME=nvim-clojure nvim --headless "+Lazy! sync" +qa
nvim --headless "+TSInstall supercollider lua" +qa

echo "Done. Open a new terminal. Put machine-local secrets in ~/.config/zsh/local.zsh (untracked)."
