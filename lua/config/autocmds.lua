local function augroup(name)
	return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Reload files that changed outside Neovim.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd.checktime()
		end
	end,
})

-- Highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

-- Keep split sizes balanced after resizing Neovim.
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Restore the last cursor position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_location"),
	callback = function(event)
		if vim.bo[event.buf].filetype == "gitcommit" or vim.b[event.buf].last_location then
			return
		end

		vim.b[event.buf].last_location = true

		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(event.buf)

		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Close utility buffers with q.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dap-float",
		"dbout",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false

		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd.close()
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = "man",
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- Wrap and spell-check prose.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_and_spell"),
	pattern = {
		"text",
		"plaintex",
		"typst",
		"gitcommit",
		"markdown",
	},
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Display JSON syntax characters instead of concealing them.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Do not continue comments automatically after inserting a newline.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("formatoptions"),
	callback = function()
		vim.opt_local.formatoptions:remove({ "r", "o" })
	end,
})

-- Create missing parent directories before writing a file.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup("create_parent_directory"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end

		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})
