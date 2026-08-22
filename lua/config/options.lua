-- Options are automatically loaded before lazy.nvim startup
-- Some default options are always set: <DOCS_LINK>
-- Add any additional options here
vim.g.snacks_animate = false

-- Use basedpyright with python
vim.g.lazyvim_python_lsp = "basedpyright"

-- Clipboard
if vim.env.SSH_CONNECTION then
	if vim.env.TMUX then
		-- tmux can handle both directions
		vim.o.clipboard = "unnamedplus"
		vim.g.clipboard = "tmux"
	elseif vim.env.HERDR_ENV then
		-- Herdr remote:
		--   yank -> local machine clipboard via OSC52
		--   paste -> normal Neovim register
		vim.o.clipboard = ""

		local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")

		vim.api.nvim_create_autocmd("TextYankPost", {
			callback = function()
				if vim.v.event.operator == "y" then
					osc52_copy(vim.v.event.regcontents, vim.v.event.regtype)
				end
			end,
		})
	else
		-- Raw SSH: use OSC52 as the clipboard provider
		vim.o.clipboard = "unnamedplus"
		vim.g.clipboard = "osc52"
	end
else
	-- Local
	vim.o.clipboard = "unnamedplus"
end
