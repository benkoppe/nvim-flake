vim.loader.enable()

vim.keymap.set("n", " ", "<Nop>", {
	silent = true,
	remap = false,
})

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.lze = {
	load = require("lzextras").loaders.with_after,
}

require("config.options")
require("config.autocmds")
require("lze").load("plugins")
require("config.keymaps")
