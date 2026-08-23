local map = vim.keymap.set

-- Move by displayed lines unless a count is supplied.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
	desc = "Down",
})
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
	desc = "Up",
})
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
	desc = "Down",
})
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
	desc = "Up",
})

-- Windows
map("n", "<C-h>", "<C-w>h", { remap = true, desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { remap = true, desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { remap = true, desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { remap = true, desc = "Go to right window" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n", "<leader>-", "<C-w>s", { remap = true, desc = "Split window below" })
map("n", "<leader>|", "<C-w>v", { remap = true, desc = "Split window right" })
map("n", "<leader>wd", "<C-w>c", { remap = true, desc = "Delete window" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>buffer #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>buffer #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>bo", function()
	Snacks.bufdelete.other()
end, { desc = "Delete other buffers" })
map("n", "<leader>bi", function()
	Snacks.bufdelete.invisible()
end, { desc = "Delete invisible buffers" })
map("n", "<leader>bD", "<cmd>bd<cr>", { desc = "Delete buffer and window" })

-- Search
map({ "i", "n", "s" }, "<Esc>", function()
	vim.cmd.nohlsearch()
	return "<Esc>"
end, {
	expr = true,
	desc = "Escape and clear search",
})

map("n", "n", "'Nn'[v:searchforward].'zv'", {
	expr = true,
	desc = "Next search result",
})
map("x", "n", "'Nn'[v:searchforward]", {
	expr = true,
	desc = "Next search result",
})
map("o", "n", "'Nn'[v:searchforward]", {
	expr = true,
	desc = "Next search result",
})
map("n", "N", "'nN'[v:searchforward].'zv'", {
	expr = true,
	desc = "Previous search result",
})
map("x", "N", "'nN'[v:searchforward]", {
	expr = true,
	desc = "Previous search result",
})
map("o", "N", "'nN'[v:searchforward]", {
	expr = true,
	desc = "Previous search result",
})

map("n", "<leader>ur", "<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-l><cr>", { desc = "Redraw and clear search" })

-- Editing
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("x", "<", "<gv")
map("x", ">", ">gv")
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Diagnostics
local function diagnostic_jump(count, severity)
	return function()
		vim.diagnostic.jump({
			count = count * vim.v.count1,
			severity = severity,
			float = true,
		})
	end
end

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "[d", diagnostic_jump(-1), { desc = "Previous diagnostic" })
map("n", "]e", diagnostic_jump(1, vim.diagnostic.severity.ERROR), { desc = "Next error" })
map("n", "[e", diagnostic_jump(-1, vim.diagnostic.severity.ERROR), { desc = "Previous error" })
map("n", "]w", diagnostic_jump(1, vim.diagnostic.severity.WARN), { desc = "Next warning" })
map("n", "[w", diagnostic_jump(-1, vim.diagnostic.severity.WARN), { desc = "Previous warning" })

-- Lists
map("n", "<leader>xl", function()
	local open = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
	local ok, err = pcall(open and vim.cmd.lclose or vim.cmd.lopen)

	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location list" })

map("n", "<leader>xq", function()
	local open = vim.fn.getqflist({ winid = 0 }).winid ~= 0
	local ok, err = pcall(open and vim.cmd.cclose or vim.cmd.copen)

	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix list" })

map("n", "[q", function()
	if package.loaded.trouble and require("trouble").is_open() then
		require("trouble").prev({
			skip_groups = true,
			jump = true,
		})
		return
	end

	local ok, err = pcall(vim.cmd.cprev)
	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Previous Trouble or quickfix item" })

map("n", "]q", function()
	if package.loaded.trouble and require("trouble").is_open() then
		require("trouble").next({
			skip_groups = true,
			jump = true,
		})
		return
	end

	local ok, err = pcall(vim.cmd.cnext)
	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Next Trouble or quickfix item" })

-- Snacks
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative numbers" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle
	.option("conceallevel", {
		off = 0,
		on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
		name = "Conceal level",
	})
	:map("<leader>uc")

map("n", "<leader>fT", function()
	Snacks.terminal()
end, { desc = "Terminal" })

map({ "n", "t" }, "<C-/>", function()
	Snacks.terminal.focus()
end, { desc = "Terminal" })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect position" })
map("n", "<leader>uI", function()
	vim.treesitter.inspect_tree()
	vim.api.nvim_input("I")
end, { desc = "Inspect Treesitter tree" })

-- Tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous tab" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("config_lua_keymaps", { clear = true }),
	pattern = "lua",
	callback = function(event)
		map({ "n", "x" }, "<localleader>r", function()
			Snacks.debug.run()
		end, {
			buffer = event.buf,
			desc = "Run Lua",
		})
	end,
})
