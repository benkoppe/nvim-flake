vim.loader.enable()

vim.keymap.set("n", " ", "<Nop>", {
	silent = true,
	remap = false,
})

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.filetypes")
require("config.autocmds")
require("lze").load("plugins")
require("config.keymaps")
