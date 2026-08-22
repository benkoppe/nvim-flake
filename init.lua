vim.loader.enable()

vim.keymap.set("n", " ", "<Nop>", {
	silent = true,
	remap = false,
})

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lze").load("plugins")
