#!/usr/bin/env bash
# Bootstrap a fresh macOS machine. Idempotent: safe to re-run.
#   git clone https://github.com/mixify/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
CONFIG="$HOME/.config"

# Pinned upstream versions (bump deliberately)
PRACTICALLI_DOTFILES_REF=5aaf2a8b7040e512ac7feede48e2e667427ec460
PRACTICALLI_CLI_CONFIG_REF=603201e56ee53eb930283b2c1f3486fa9219b45e
PREZTO_REF=a7c61670c3492358bfe1dd793cb891987bbb4f49
PDOT="$HOME/.local/share/practicalli/dotfiles"

# 1. Homebrew + packages
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
brew bundle --file="$DOTFILES/Brewfile"

# 2. Pinned upstream clones
clone_at() { # url dir ref [--recursive]
  if [[ ! -d "$2/.git" ]]; then
    mkdir -p "$(dirname "$2")"; git clone ${4:-} "$1" "$2"
  fi
  git -C "$2" checkout -q "$3" 2>/dev/null || { git -C "$2" fetch -q origin && git -C "$2" checkout -q "$3"; }
}
clone_at https://github.com/practicalli/dotfiles.git "$PDOT" "$PRACTICALLI_DOTFILES_REF"
clone_at https://github.com/practicalli/clojure-cli-config.git "$CONFIG/clojure" "$PRACTICALLI_CLI_CONFIG_REF"
clone_at https://github.com/sorin-ionescu/prezto.git "$CONFIG/zsh/.zprezto" "$PREZTO_REF" --recursive
git -C "$CONFIG/zsh/.zprezto" submodule update -q --init --recursive

# My local changes on top of practicalli/dotfiles (kitty keys, local.zsh hook)
if git -C "$PDOT" apply --check "$DOTFILES/patches/practicalli-dotfiles.patch" 2>/dev/null; then
  git -C "$PDOT" apply "$DOTFILES/patches/practicalli-dotfiles.patch"
fi

# 3. Symlinks (existing real files are moved to ~/.dotfiles-backup/)
link() { # absolute-src dst
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    [[ "$(readlink "$dst")" == "$src" ]] && return 0
    mkdir -p "$BACKUP" && mv "$dst" "$BACKUP/$(basename "$dst")"
    echo "backed up $dst -> $BACKUP"
  fi
  ln -s "$src" "$dst" && echo "linked $dst"
}
# practicalli shell stack (zshenv sets ZDOTDIR=~/.config/zsh)
link "$PDOT/zsh/zshenv"            "$HOME/.zshenv"
link "$PDOT/zsh/zshrc"             "$CONFIG/zsh/.zshrc"
link "$PDOT/zsh/zprofile"          "$CONFIG/zsh/.zprofile"
link "$PDOT/zsh/zpreztorc"         "$CONFIG/zsh/.zpreztorc"
link "$PDOT/shell/shell-aliases"   "$CONFIG/shell-aliases"
link "$PDOT/shell/starship.toml"   "$CONFIG/starship.toml"
link "$PDOT/kitty"                 "$CONFIG/kitty"
# mine
link "$DOTFILES/zsh/local.zsh"     "$CONFIG/zsh/local.zsh"
link "$DOTFILES/.vimrc"            "$HOME/.vimrc"
link "$DOTFILES/.config/nvim"      "$CONFIG/nvim"          # SuperCollider
link "$DOTFILES/.config/nvim-clojure" "$CONFIG/nvim-clojure"  # nvim-clj
link "$DOTFILES/clojure"           "$HOME/clojure"

# 4. iTerm2: load settings from this repo
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# 5. Neovim plugins + parsers
nvim --headless "+Lazy! sync" +qa
NVIM_APPNAME=nvim-clojure nvim --headless "+Lazy! sync" +qa
nvim --headless "+TSInstall supercollider lua" +qa

echo "Done. Open a new terminal. Secrets go in ~/.config/zsh/local.secrets.zsh (untracked)."
