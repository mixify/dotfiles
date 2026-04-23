# dotfiles

My development environment for SuperCollider + Neovim + Claude Code.

## Setup

```bash
# Clone
git clone https://github.com/mixify/dotfiles.git ~/dotfiles

# Symlink
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua

# Install plugins (first launch)
nvim --headless "+Lazy! sync" +qa

# Install treesitter parser
nvim --headless "+TSInstall supercollider lua" +qa
```

### Requirements

- [Neovim](https://neovim.io/) >= 0.7
- [SuperCollider](https://supercollider.github.io/downloads)
- [Claude Code](https://claude.ai/code) CLI
- [tree-sitter CLI](https://www.npmjs.com/package/tree-sitter-cli) (`npm install -g tree-sitter-cli`)

## Cheat Sheet

**Leader key: `,`**

### Workspace

| Key | Action |
|---|---|
| `,go` | Launch full workspace (editor + Claude Code + SC post window) |
| `Esc Esc` | Exit terminal mode back to Neovim |
| `Ctrl+W h/l` | Switch between editor and right pane |
| `Ctrl+W j/k` | Switch between Claude Code and post window |

### SuperCollider

| Key | Action |
|---|---|
| `,st` | Start sclang |
| `,sk` | Recompile class library |
| `F1` | Boot server (`s.boot`) |
| `F2` | Server meter (`s.meter`) |
| `F12` | Hard stop / panic |
| `Ctrl+E` | Send block (n/i) / selection (v) |
| `Option+E` | Send current line |
| `Enter` | Toggle post window |
| `Option+Enter` | Toggle post window (insert mode) |
| `Option+L` | Clear post window |
| `Ctrl+K` | Show method signature |
| `K` | Open help doc for class under cursor |

### Claude Code

| Key | Action |
|---|---|
| `,ac` | Toggle Claude Code |
| `,af` | Focus Claude Code |
| `,as` | Send selection to Claude (visual) |
| `,ab` | Add current buffer to Claude |
| `,ar` | Resume Claude |
| `,aC` | Continue Claude |
| `,am` | Select Claude model |
| `,aa` | Accept diff |
| `,ad` | Deny diff |
| `Cmd+Opt+K` | Send selection (visual) / add file (normal) |

> **Note:** `Cmd+Opt+K` requires iTerm2 key mapping:
> Preferences → Profiles → Keys → Key Mappings → `+`
> Shortcut: `Cmd+Opt+K` → Action: Send Hex Codes → `1b 5b 32 35 7e`

### Completion (insert mode)

| Key | Action |
|---|---|
| `Tab` / `Shift+Tab` | Cycle completions |
| `Ctrl+J` | Trigger completion manually |
| `Ctrl+N` / `Ctrl+P` | Next / previous item |
| `Enter` | Confirm selection |

### General Neovim

| Key | Action |
|---|---|
| `,y` | Yank to system clipboard |
| `,e` / `,q` | Next / previous buffer |
| `,f` | Alternate buffer |
| `,1`-`,9` | Jump to buffer N |
| `,r` | Toggle relative numbers |
| `Space` | Toggle fold |
| `Ctrl+P` | Find files (telescope) |
| `,g` | Live grep |
| `,b` | Buffer list |
| `s` | Hop (2-char jump) |
| `gc` | Toggle comment |
| `ga` | Easy align |
| `F5` | Undo tree |
| `gV` | Highlight last insert |

## Plugins

| Plugin | Purpose |
|---|---|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [scnvim](https://github.com/davidgranstrom/scnvim) | SuperCollider frontend |
| [claudecode.nvim](https://github.com/coder/claudecode.nvim) | Claude Code integration |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in gutter |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git wrapper |
| [hop.nvim](https://github.com/phaazon/hop.nvim) | Easy motion |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Rainbow brackets |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding popup |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto close brackets |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments |
| [vim-easy-align](https://github.com/junegunn/vim-easy-align) | Align text |
| [undotree](https://github.com/mbbill/undotree) | Undo history |
| [jellybeans.vim](https://github.com/nanotech/jellybeans.vim) | Colorscheme |

## Workspace Layout

```
,go launches:
┌──────────────┬──────────────────┐
│              │   Claude Code    │
│              │     (70%)       │
│   Editor     ├──────────────────┤
│              │  SC Post Window  │
│              │     (30%)       │
└──────────────┴──────────────────┘
```
