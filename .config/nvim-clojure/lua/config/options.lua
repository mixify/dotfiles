local o = vim.opt
o.number = true
o.termguicolors = true
o.signcolumn = "yes"      -- LSP 진단 표시로 화면이 흔들리지 않게
o.expandtab = true        -- Clojure 관례: 공백 2칸
o.shiftwidth = 2
o.tabstop = 2
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 300
o.clipboard = "unnamedplus"  -- 결과를 시스템 클립보드로 바로 복사
o.mouse = ""                 -- vim 키에 익숙해지기 위해 마우스 비활성화

-- 한글 IME를 켜둔 채 명령을 쳤을 때의 안전장치 (:ㅈ -> :w, :ㅂ -> :q)
for kor, en in pairs({ ["ㅈ"] = "w", ["ㅂ"] = "q", ["ㅈㅂ"] = "wq", ["ㅂㅁ"] = "qa" }) do
  vim.cmd(string.format(
    "cnoreabbrev <expr> %s (getcmdtype() == ':' && getcmdline() ==# '%s') ? '%s' : '%s'",
    kor, kor, en, kor))
end

-- Insert 모드를 나가면 입력기를 영어로 (im-select가 있을 때만)
if vim.fn.executable("im-select") == 1 then
  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function() vim.fn.jobstart({ "im-select", "com.apple.keylayout.ABC" }) end,
  })
end
