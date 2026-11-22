-- Clojure 학습용 Neovim 설정 (기존 설정은 ~/.config/nvim.bak-20261110 에 백업됨)
-- 참고: https://practical.li/neovim/ , Conjure/nvim-paredit README

-- leader: Space / localleader: ","  (practical.li 방식. Conjure 키가 전부 localleader 아래에 붙는다)
-- 반드시 lazy.nvim 로드 전에 설정해야 플러그인 키맵에 반영된다.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- lazy.nvim 부트스트랩 (없으면 clone)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("lazy").setup("plugins", { change_detection = { notify = false } })
