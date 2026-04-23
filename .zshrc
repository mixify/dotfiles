alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

alias ll='ls -alh --color'

# alias ymp3='~/Downloads/yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%(title)s.%(ext)s"' "$1"

# Created by `pipx` on 2024-07-21 18:25:31
export PATH="$PATH:/Users/soenmupark/.local/bin"
export PATH="$PATH:$HOME/scripts"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export ITCH_USER="seonjisoup"
export ITCH_GAME="egolution"

export VIRTUAL_ENV="$HOME/.venvs/global-env"
export PATH="$VIRTUAL_ENV/bin:$PATH"


export PATH="$HOME/.local/bin:$PATH"
alias claude='claude --dangerously-skip-permissions'
