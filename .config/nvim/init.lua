-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys (matching .vimrc)
vim.g.mapleader = ","
vim.g.maplocalleader = "`"

--- Options (from .vimrc) ---

-- Timeout: give enough time for leader sequences
vim.opt.timeout = true
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10    -- fast escape sequence detection (distinguishes Esc from Esc+[...)

-- UI
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 3
vim.opt.showcmd = true
vim.opt.title = true
vim.opt.visualbell = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.laststatus = 2
vim.opt.numberwidth = 5
vim.opt.shortmess:append("I")

-- Buffers / windows
vim.opt.hidden = true
vim.opt.history = 1000
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Wrapping
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "> " }

-- Folding
vim.opt.foldmethod = "indent"
vim.opt.foldnestmax = 10
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "0"

-- Search
vim.opt.gdefault = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.matchtime = 2

-- Indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0       -- uses tabstop
vim.opt.softtabstop = -1     -- uses shiftwidth
vim.opt.shiftround = true
vim.opt.smarttab = true

-- Files
vim.opt.autoread = true
vim.opt.confirm = true
vim.opt.backup = false
vim.opt.swapfile = true
vim.opt.undofile = true
vim.opt.undolevels = 500
vim.opt.undoreload = 10000

-- Mouse disabled (matching .vimrc)
vim.opt.mouse = ""

-- Wildmenu
vim.opt.wildignore:append("*.bak,*.swp,*.swo")
vim.opt.wildignore:append("*.a,*.o,*.so,*.pyc,*.class")
vim.opt.wildignore:append("*.jpg,*.jpeg,*.gif,*.png,*.pdf")
vim.opt.wildignore:append("*/.git*,*.tar,*.zip")
vim.opt.wildmode = "longest:full,list:full"

-- Format options: join comments properly
vim.opt.formatoptions:append("j")

-- Completion
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.tags:append(vim.fn.stdpath("cache") .. "/scnvim/tags")

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = [[^\.$]]
vim.g.netrw_liststyle = 3

-- SuperCollider: ensure sclang is on PATH
vim.env.PATH = "/Applications/SuperCollider.app/Contents/MacOS:" .. vim.env.PATH

--- Keymaps (from .vimrc) ---
local map = vim.keymap.set

-- Terminal: double Esc to exit terminal mode back to Neovim normal mode
-- Single Esc goes to Claude Code's vim mode
map("t", "<Esc><Esc>", [[<C-\><C-n>]])


-- Yank to system clipboard
map("n", "<Leader>y", '"+y')
map("v", "<Leader>y", '"+y')

-- Toggle relativenumber
map("n", "<Leader>r", ":set relativenumber!<CR>", { silent = true })

-- Wrapped line navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Buffer switching
map("n", "<Leader>e", ":bnext<CR>")
map("n", "<Leader>q", ":bprevious<CR>")
map("n", "<Leader>f", ":b#<CR>")
for i = 1, 9 do
    map("n", "<Leader>" .. i, ":" .. i .. "b<CR>")
end
map("n", "<Leader>0", ":10b<CR>")

-- Highlight last inserted text
map("n", "gV", "'[V']")

-- Toggle folding with Space (in normal mode, non-leader)
map("n", "<Space>", "@=(foldlevel('.')?'za':\"\\<Space>\")<CR>", { silent = true })

--- SC Workspace: single command to set up the full layout ---
--- Editor (left) | Claude Code (top-right)
---               | SC Post Window (bottom-right)
local function sc_workspace()
    -- Close all splits, keep current buffer (editor)
    vim.cmd("only")
    local editor_win = vim.api.nvim_get_current_win()

    -- Force-load claudecode plugin so :ClaudeCode is available
    require("lazy").load({ plugins = { "claudecode.nvim" } })

    -- Let Claude Code open its own vertical split on the right
    vim.cmd("ClaudeCode")

    -- After Claude Code opens, split below it for postwin
    vim.defer_fn(function()
        -- Find the Claude Code terminal window
        local claude_win = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "terminal" and win ~= editor_win then
                claude_win = win
                break
            end
        end

        if claude_win then
            -- Focus Claude Code window, split below for postwin
            vim.api.nvim_set_current_win(claude_win)
            vim.cmd("belowright split")
            local right_bot_win = vim.api.nvim_get_current_win()
            -- 30% height for postwin, 70% for Claude Code
            local total_height = vim.o.lines
            vim.cmd("resize " .. math.floor(total_height * 0.3))

            -- Create scnvim postwin buffer and place it here
            local postwin = require("scnvim.postwin")
            local buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_option(buf, "filetype", "scnvim")
            pcall(vim.api.nvim_buf_set_name, buf, "[scnvim]")
            postwin.buf = buf
            postwin.win = right_bot_win
            vim.api.nvim_win_set_buf(right_bot_win, buf)
        end

        -- Go to editor and start sclang
        vim.api.nvim_set_current_win(editor_win)
        vim.cmd("SCNvimStart")

        -- Generate tags after sclang finishes booting
        vim.defer_fn(function()
            vim.cmd("SCNvimGenerateAssets")
        end, 3000)
    end, 500)
end

vim.api.nvim_create_user_command("SCWorkspace", sc_workspace, {})
map("n", "<Leader>go", "<cmd>SCWorkspace<CR>", { desc = "SC + Claude workspace" })

--- Autocommands ---

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.c", "*.cpp", "*.css", "*.html", "*.py", "*.sh", "*.tex", "*.yaml", "*.yml", "*.scd", "*.sc" },
    callback = function()
        local save = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(save)
    end,
})

-- Filetype rules
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.md",
    callback = function() vim.bo.filetype = "markdown"; vim.bo.textwidth = 79 end,
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.tex",
    callback = function() vim.bo.filetype = "tex"; vim.bo.textwidth = 79 end,
})

--- Plugins ---
require("lazy").setup({
    -- Colorscheme: jellybeans (matching .vimrc)
    {
        "nanotech/jellybeans.vim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.jellybeans_overrides = {
                background = { guibg = "none" },
                SignColumn = { guibg = "none" },
            }
            vim.cmd("colorscheme jellybeans")
        end,
    },

    -- Statusline (lualine replaces lightline)
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({
                options = {
                    theme = "jellybeans",
                    section_separators = "",
                    component_separators = "|",
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },
                    lualine_c = { "buffers" },
                    lualine_x = { "fileformat", "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- Git signs in gutter (replaces vim-signify)
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end,
    },

    -- Git wrapper (fugitive, same as .vimrc)
    "tpope/vim-fugitive",

    -- Easy motion
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function()
            local hop = require("hop")
            hop.setup()
            map("n", "s", ":HopChar2<CR>", { silent = true })
        end,
    },

    -- Treesitter: better syntax highlighting + rainbow brackets
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- Enable treesitter highlighting for all filetypes with a parser
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },

    -- Rainbow brackets (requires treesitter)
    {
        "HiPhish/rainbow-delimiters.nvim",
        config = function()
            require("rainbow-delimiters.setup").setup({})
        end,
    },

    -- Which-key: shows keybinding popup
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- Commenting (replaces tcomment)
    {
        "numToStr/Comment.nvim",
        config = true,
    },

    -- Easy align (same as .vimrc)
    {
        "junegunn/vim-easy-align",
        config = function()
            map("x", "ga", "<Plug>(EasyAlign)")
            map("n", "ga", "<Plug>(EasyAlign)")
        end,
    },

    -- Undo tree
    {
        "mbbill/undotree",
        keys = { { "<F5>", ":UndotreeToggle<CR>", desc = "Undotree" } },
    },

    -- Fuzzy finder (replaces ctrlp)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<Leader>g", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
            { "<Leader>b", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
        },
    },

    -- Completion engine
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "quangnguyen30192/cmp-nvim-tags",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "luasnip" },
                    { name = "tags" },
                }),
            })
        end,
    },

    -- scnvim: SuperCollider frontend
    {
        "davidgranstrom/scnvim",
        ft = "supercollider",
        config = function()
            local scnvim = require("scnvim")
            local scmap = scnvim.map
            local scmap_expr = scnvim.map_expr
            scnvim.setup({
                keymaps = {
                    ["<M-e>"] = scmap("editor.send_line", { "i", "n" }),
                    ["<C-e>"] = {
                        scmap("editor.send_block", { "i", "n" }),
                        scmap("editor.send_selection", "x"),
                    },
                    ["<CR>"] = scmap("postwin.toggle"),
                    ["<M-CR>"] = scmap("postwin.toggle", "i"),
                    ["<M-l>"] = scmap("postwin.clear", { "n", "i" }),
                    ["<C-k>"] = scmap("signature.show", { "n", "i" }),
                    ["<F12>"] = scmap("sclang.hard_stop", { "n", "x", "i" }),
                    ["<Leader>st"] = scmap("sclang.start"),
                    ["<Leader>sk"] = scmap("sclang.recompile"),
                    ["<F1>"] = scmap_expr("s.boot"),
                    ["<F2>"] = scmap_expr("s.meter"),
                },
                editor = {
                    highlight = { color = "IncSearch" },
                },
                postwin = {
                    float = { enabled = false },
                    horizontal = true,
                    direction = "bot",
                    size = 10,
                },
            })
        end,
    },

    -- Claude Code integration
    {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    focus_after_send = true,
  },
  config = true,
  cmd = { "ClaudeCode", "ClaudeCodeSend", "ClaudeCodeFocus", "ClaudeCodeAdd", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny", "ClaudeCodeSelectModel" },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    { "<F13>", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude (Cmd+Opt+K)" },
    { "<F13>", "<cmd>ClaudeCodeAdd %<cr>", mode = "n", desc = "Add current file to Claude (Cmd+Opt+K)" },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
},
})
