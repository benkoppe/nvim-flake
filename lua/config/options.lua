-- Options are automatically loaded before lazy.nvim startup
-- Some default options are always set: <DOCS_LINK>
-- Add any additional options here
vim.g.snacks_animate = false

-- Use basedpyright with python
vim.g.lazyvim_python_lsp = "basedpyright"

-- Copy over ssh
vim.o.clipboard = "unnamedplus"
vim.g.clipboard = vim.env.TMUX and "tmux" or "osc52"
