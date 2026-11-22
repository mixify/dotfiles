return {
  -- Conjure: nREPL 클라이언트. 폼 단위로 평가하고 결과를 로그 버퍼/인라인으로 본다.
  {
    "Olical/conjure",
    ft = { "clojure", "edn" },
    init = function()
      -- HUD(떠다니는 결과창)는 끈다: 인라인 결과 + 필요할 때 ,lv 로 로그를 연다 (practical.li 권장)
      vim.g["conjure#log#hud#enabled"] = false
      -- nREPL이 없을 때 Conjure가 멋대로 babashka REPL을 띄우지 않게 한다.
      -- 우리는 항상 `bb repl`로 직접 nREPL을 띄우고 :ConjureConnect 로 붙는다.
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false
      -- 평가 결과를 레지스터 C 에 넣어 "Cp 로 붙여넣을 수 있게 (practical.li)
      vim.g["conjure#eval#result_register"] = "C"

      -- Ctrl+e = 블록(폼) 평가. 평소 쓰던 SuperCollider 단축키와 같은 손맛.
      --   Normal/Insert : 커서가 속한 최상위 폼 평가 (,er 와 같음. (comment ...) 안에서는 안쪽 폼만)
      --   Visual        : 선택 영역 평가
      -- Normal 모드의 기본 <C-e>(화면 스크롤)는 clojure 버퍼에서만 덮어쓴다.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "clojure", "edn" },
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true }
          vim.keymap.set({ "n", "i" }, "<C-e>", "<Cmd>ConjureEvalRootForm<CR>",
            vim.tbl_extend("force", o, { desc = "Conjure eval root form" }))
          vim.keymap.set("x", "<C-e>", ":<C-u>ConjureEvalVisual<CR>",
            vim.tbl_extend("force", o, { desc = "Conjure eval selection" }))
        end,
      })
    end,
  },

  -- paredit: slurp/barf/raise/wrap 같은 구조적 편집. treesitter 기반.
  {
    "julienvincent/nvim-paredit",
    ft = { "clojure", "fennel", "scheme", "lisp" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local paredit = require("nvim-paredit")
      paredit.setup({
        indent = { enabled = true },  -- 편집 후 자동 들여쓰기
      })
      -- 기본 키: >) slurp→  <) barf→  <( slurp←  >( barf←  <localleader>@ raise form  <localleader>o raise element
      -- 기본값에 없는 wrap 은 직접 매핑: ,w( ,w[ ,w{  (요소 감싸기)  ,W( (폼 감싸기)
      local function wrap(l, r, form)
        return function()
          if form then paredit.wrap.wrap_enclosing_form_under_cursor(l, r)
          else paredit.wrap.wrap_element_under_cursor(l, r) end
        end
      end
      local map = vim.keymap.set
      for _, p in ipairs({ { "(", ")" }, { "[", "]" }, { "{", "}" } }) do
        map("n", "<localleader>w" .. p[1], wrap(p[1], p[2], false), { desc = "paredit wrap element " .. p[1] })
        map("n", "<localleader>W" .. p[1], wrap(p[1], p[2], true), { desc = "paredit wrap form " .. p[1] })
      end
    end,
  },

  -- Treesitter: 구문 강조 + paredit이 폼 구조를 읽는 데 필요. 0.12는 main 브랜치 사용.
  -- (파서 컴파일에 tree-sitter CLI와 C 컴파일러가 필요: brew install tree-sitter-cli)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "clojure", "lua", "markdown" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "clojure", "lua", "markdown" },  -- edn은 clojure 파서를 공유하지 않으므로 제외
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  -- LSP: clojure-lsp (clj-kondo 진단을 내장). 서버 기본 설정은 nvim-lspconfig가 제공한다.
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.enable("clojure_lsp")
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local o = { buffer = ev.buf }
          -- K / gd 는 Conjure(nREPL)도 매핑한다. REPL이 붙으면 Conjure가, 아니면 LSP가 쓰이는 식으로 보완 관계.
          vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, vim.tbl_extend("force", o, { desc = "LSP rename" }))
          vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("force", o, { desc = "LSP code action" }))
          vim.keymap.set("n", "<leader>lR", vim.lsp.buf.references, vim.tbl_extend("force", o, { desc = "LSP references" }))
          vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", o, { desc = "diagnostic" }))
          vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end,
            vim.tbl_extend("force", o, { desc = "LSP format" }))
        end,
      })
    end,
  },

  -- 괄호 색칠: 중첩 깊이를 눈으로 구분 (Lisp 입문에 큰 도움)
  {
    "HiPhish/rainbow-delimiters.nvim",
    ft = { "clojure", "edn", "lua" },
  },

  -- 단축키를 잊었을 때 팝업으로 보여준다 (<leader>, <localleader> 누르고 잠시 대기)
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
}
