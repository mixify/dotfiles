-- SuperCollider indenter — stack-based, deterministic
--
-- Two rules:
-- 1. Line STARTS with closers (} ] )) → dedent this line
-- 2. Line ENDS with openers ({ [ () → indent next line
--
-- Standalone ( ) on own line → col 0, no indent change
-- Everything else (balanced mid-line pairs) → no effect

local M = {}

local function count_trailing_openers(code)
	-- Count openers at end of line (after last non-bracket char)
	local trailing = code:match("[{%(%[]+%s*$")
	return trailing and #trailing or 0
end

local function count_leading_closers(code)
	-- Count closers at start of line (before first non-bracket char)
	local leading = code:match("^([}%)%]]+)")
	return leading and #leading or 0
end

function M.indent_buffer()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local indent = 0
	local tab = "\t"
	local result = {}

	for _, line in ipairs(lines) do
		local stripped = line:match("^%s*(.-)%s*$")

		-- Blank lines stay blank
		if stripped == "" then
			table.insert(result, "")
			goto continue
		end

		-- Standalone ( or ) — SC execution block delimiters
		if stripped == "(" or stripped == ")" then
			indent = 0
			table.insert(result, stripped)
			goto continue
		end

		-- Strip comments and strings for analysis
		local code = stripped:match("^(.-)//") or stripped
		code = code:gsub('"[^"]*"', "")

		-- Step 1: leading closers dedent THIS line
		local lead = count_leading_closers(code)
		if lead > 0 then
			indent = math.max(0, indent - lead)
		end

		-- Apply indent to this line
		local indented = (indent > 0 and string.rep(tab, indent) or "") .. stripped
		table.insert(result, indented)

		-- Step 2: trailing openers indent NEXT line
		local trail = count_trailing_openers(code)
		if trail > 0 then
			indent = indent + trail
		end

		::continue::
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
end

return M